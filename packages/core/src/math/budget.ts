import { BillingCycle, Subscription, Budget503020Split, IncomeHealthStatus, WhatIfSavings } from '../types';
import { formatCurrency } from '../i18n';

export { formatCurrency };

/**
 * Arrondit strictement à 2 décimales pour éliminer les dérives IEEE 754
 */
export function roundToCents(amount: number): number {
  if (isNaN(amount) || !isFinite(amount)) return 0;
  return Math.round((amount + Number.EPSILON) * 100) / 100;
}

export function normalizeMonthlyAmount(amount: number, cycle: BillingCycle | string): number {
  if (!Number.isFinite(amount) || amount <= 0) return 0;
  const normCycle = (cycle || 'Monthly').toLowerCase().replace(/[\s\-_]/g, '');
  switch (normCycle) {
    case 'daily':
      return (amount * 365) / 12;
    case 'weekly':
      return (amount * 52) / 12;
    case 'biweekly':
    case 'fortnightly':
      return (amount * 26) / 12;
    case 'monthly':
      return amount;
    case 'quarterly':
      return amount / 3;
    case 'semiannual':
    case 'semiannually':
    case 'halfyearly':
      return amount / 6;
    case 'yearly':
    case 'annual':
    case 'annually':
      return amount / 12;
    default:
      return amount;
  }
}

export function normalizeYearlyAmount(amount: number, cycle: BillingCycle | string): number {
  return normalizeMonthlyAmount(amount, cycle) * 12;
}


export function calculateTotalMonthlyCost(
  subscriptions: Subscription[],
  excludedIds: Set<string> = new Set()
): number {
  const sum = subscriptions
    .filter((sub) => !excludedIds.has(sub.id) && sub.status !== 'paused')
    .reduce((total, sub) => total + normalizeMonthlyAmount(sub.amount, sub.cycle), 0);
  return roundToCents(sum);
}

export function calculateTotalYearlyCost(
  subscriptions: Subscription[],
  excludedIds: Set<string> = new Set()
): number {
  return roundToCents(subscriptions.filter(sub => !excludedIds.has(sub.id) && sub.status !== 'paused').reduce((sum, sub) => sum + normalizeYearlyAmount(sub.amount, sub.cycle), 0));
}

export function calculateWhatIfSavings(
  subscriptions: Subscription[],
  excludedIds: Set<string>
): WhatIfSavings {
  const baselineMonthly = calculateTotalMonthlyCost(subscriptions);
  const whatIfMonthly = calculateTotalMonthlyCost(subscriptions, excludedIds);

  const monthlySavings = roundToCents(Math.max(0, baselineMonthly - whatIfMonthly));
  const yearlySavings = roundToCents(monthlySavings * 12);
  const savingsPercentage = baselineMonthly > 0 ? (monthlySavings / baselineMonthly) * 100 : (excludedIds.size > 0 ? 100 : 0);


  return {
    monthlySavings,
    yearlySavings,
    remainingMonthlyCost: whatIfMonthly,
    excludedCount: excludedIds.size,
    totalCount: subscriptions.length,
    savingsPercentage
  };
}

export function calculate503020Split(
  monthlyIncome: number,
  totalSubscriptionsMonthly: number
): Budget503020Split {
  const income = Math.max(0, monthlyIncome);
  const needs50 = income * 0.5;
  const wants30 = income * 0.3;
  const savings20 = income * 0.2;

  const freeCashFlow = income - totalSubscriptionsMonthly;
  const percentage = income > 0 ? (totalSubscriptionsMonthly / income) * 100 : 0;

  let healthStatus: IncomeHealthStatus = 'unknown';
  let healthMessage = 'Configure your monthly income to get 50/30/20 clarity.';

  if (income > 0) {
    if (percentage <= 5) {
      healthStatus = 'optimal';
      healthMessage = 'Serene flow! Subscriptions represent a minimal portion of your budget.';
    } else if (percentage <= 15) {
      healthStatus = 'healthy';
      healthMessage = 'Healthy balance. Your recurring spending is well within bounds.';
    } else if (percentage <= 30) {
      healthStatus = 'warning';
      healthMessage = 'High commitments. Review non-essential subscriptions to free up cash flow.';
    } else {
      healthStatus = 'critical';
      healthMessage = 'Critical load! Recurring commitments exceed safe 50/30/20 recommendations.';
    }
  }

  return {
    monthlyIncome: income,
    needsTarget: needs50,
    wantsTarget: wants30,
    savingsTarget: savings20,
    fixedCommitmentsTotal: totalSubscriptionsMonthly,
    freeCashFlowRemaining: freeCashFlow,
    healthStatus,
    healthMessage,
    needs50Limit: needs50,
    subscriptionsPercentageOfIncome: percentage,
    isBudgetHealthy: income > 0 && percentage <= 15
  };
}

export function calculateCategoryBreakdown(
  subscriptions: Subscription[],
  excludedIds: Set<string> = new Set()
): Record<string, { total: number; percentage: number; count: number; subscriptions: Subscription[] }> {
  const activeSubs = subscriptions.filter(
    (sub) => !excludedIds.has(sub.id) && sub.status !== 'paused'
  );
  const total = activeSubs.reduce(
    (sum, sub) => sum + normalizeMonthlyAmount(sub.amount, sub.cycle),
    0
  );

  const breakdown: Record<string, { total: number; percentage: number; count: number; subscriptions: Subscription[] }> = {};

  activeSubs.forEach((sub) => {
    const cat = String(sub.category || 'General');
    if (!breakdown[cat]) {
      breakdown[cat] = { total: 0, percentage: 0, count: 0, subscriptions: [] };
    }
    const entry = breakdown[cat];
    if (entry) {
      const monthly = normalizeMonthlyAmount(sub.amount, sub.cycle);
      entry.total += monthly;
      entry.count += 1;
      entry.subscriptions.push(sub);
    }
  });

  Object.keys(breakdown).forEach((cat) => {
    const entry = breakdown[cat];
    if (entry) {
      entry.percentage = total > 0 ? (entry.total / total) * 100 : 0;
    }
  });

  return breakdown;
}

export interface UpcomingOccurrence {
  subscription: Subscription;
  dueDate: Date;
  daysRemaining: number;
  formattedDate: string;
}

/** Calendar dates stay in local time; month-end recurrences keep their original anchor. */
function parseCalendarDate(value: string): Date | null {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
  if (!match) return null;
  const [year, month, day] = match.slice(1).map(Number) as [number, number, number];
  const date = new Date(year, month - 1, day);
  return date.getFullYear() === year && date.getMonth() === month - 1 && date.getDate() === day ? date : null;
}

function nextOccurrence(start: Date, cycle: string, reference: Date, strictlyAfter = false): Date {
  const c = cycle.toLowerCase().replace(/[\s_-]/g, '');
  const dayStep = ({ daily: 1, weekly: 7, biweekly: 14, fortnightly: 14 } as Record<string, number>)[c];
  const ref = new Date(reference.getFullYear(), reference.getMonth(), reference.getDate());
  if (strictlyAfter) ref.setDate(ref.getDate() + 1);
  if (start >= ref) return new Date(start);
  if (dayStep) {
    const days = Math.round((Date.UTC(ref.getFullYear(), ref.getMonth(), ref.getDate()) - Date.UTC(start.getFullYear(), start.getMonth(), start.getDate())) / 86400000);
    const due = new Date(start);
    due.setDate(start.getDate() + Math.ceil(days / dayStep) * dayStep);
    return due;
  }
  const monthStep = ({ quarterly: 3, semiannual: 6, semiannually: 6, halfyearly: 6, yearly: 12, annual: 12, annually: 12 } as Record<string, number>)[c] || 1;
  const monthDiff = (ref.getFullYear() - start.getFullYear()) * 12 + ref.getMonth() - start.getMonth();
  let step = Math.max(0, Math.floor(monthDiff / monthStep));
  const at = (index: number) => {
    const date = new Date(start.getFullYear(), start.getMonth() + index * monthStep, 1);
    const lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
    date.setDate(Math.min(start.getDate(), lastDay));
    return date;
  };
  let due = at(step);
  if (due < ref) due = at(++step);
  return due;
}

export function calculateUpcomingOccurrences(subscriptions: Subscription[], referenceDate: Date = new Date(), daysForward = 60): UpcomingOccurrence[] {
  if (!Number.isFinite(referenceDate.getTime()) || !Number.isFinite(daysForward) || daysForward < 0) return [];
  const refDay = Date.UTC(referenceDate.getFullYear(), referenceDate.getMonth(), referenceDate.getDate());
  const occurrences: UpcomingOccurrence[] = [];
  for (const subscription of subscriptions) {
    if (subscription.status === 'paused') continue;
    const start = parseCalendarDate(subscription.startDate);
    if (!start) continue;
    const dueDate = nextOccurrence(start, subscription.cycle || 'Monthly', referenceDate);
    const daysRemaining = Math.round((Date.UTC(dueDate.getFullYear(), dueDate.getMonth(), dueDate.getDate()) - refDay) / 86400000);
    if (daysRemaining <= daysForward) occurrences.push({ subscription, dueDate, daysRemaining, formattedDate: dueDate.toLocaleDateString('en-US', { day: 'numeric', month: 'short' }) });
  }
  return occurrences.sort((a, b) => a.daysRemaining - b.daysRemaining);
}

export function calculateNextRenewalDate(lastChargeDateStr: string, cycle = 'monthly', referenceDate = new Date()): string {
  const start = parseCalendarDate(lastChargeDateStr);
  if (!start || !Number.isFinite(referenceDate.getTime())) {
    const fallback = new Date(referenceDate);
    return `${fallback.getFullYear()}-${String(fallback.getMonth() + 1).padStart(2, '0')}-${String(fallback.getDate()).padStart(2, '0')}`;
  }
  const next = nextOccurrence(start, cycle, referenceDate, false);
  return `${next.getFullYear()}-${String(next.getMonth() + 1).padStart(2, '0')}-${String(next.getDate()).padStart(2, '0')}`;
}

/** All scheduled charges in a calendar month, retaining the original cycle anchor. */
export function calculateMonthOccurrences(subscriptions: Subscription[], year: number, month: number): UpcomingOccurrence[] {
  const first = new Date(year, month, 1);
  const last = new Date(year, month + 1, 0);
  if (!Number.isFinite(first.getTime()) || !Number.isFinite(last.getTime())) return [];
  const result: UpcomingOccurrence[] = [];
  for (const subscription of subscriptions) {
    if (subscription.status === 'paused') continue;
    const start = parseCalendarDate(subscription.startDate);
    if (!start) continue;
    let dueDate = nextOccurrence(start, subscription.cycle, first);
    while (dueDate <= last) {
      result.push({ subscription, dueDate, daysRemaining: dueDate.getDate() - 1, formattedDate: String(dueDate.getDate()) });
      dueDate = nextOccurrence(start, subscription.cycle, dueDate, true);
    }
  }
  return result.sort((a, b) => a.dueDate.getTime() - b.dueDate.getTime());
}
