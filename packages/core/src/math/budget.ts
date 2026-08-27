import { BillingCycle, Subscription, Budget503020Split, IncomeHealthStatus, WhatIfSavings } from '../types';
import { formatCurrency } from '../i18n';

export { formatCurrency };

export function normalizeMonthlyAmount(amount: number, cycle: BillingCycle | string): number {
  if (isNaN(amount) || amount <= 0) return 0;
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
  return subscriptions
    .filter((sub) => !excludedIds.has(sub.id) && sub.status !== 'paused')
    .reduce((sum, sub) => sum + normalizeMonthlyAmount(sub.amount, sub.cycle), 0);
}

export function calculateTotalYearlyCost(
  subscriptions: Subscription[],
  excludedIds: Set<string> = new Set()
): number {
  return calculateTotalMonthlyCost(subscriptions, excludedIds) * 12;
}

export function calculateWhatIfSavings(
  subscriptions: Subscription[],
  excludedIds: Set<string>
): WhatIfSavings {
  const baselineMonthly = calculateTotalMonthlyCost(subscriptions);
  const whatIfMonthly = calculateTotalMonthlyCost(subscriptions, excludedIds);

  const monthlySavings = Math.max(0, baselineMonthly - whatIfMonthly);
  const yearlySavings = monthlySavings * 12;
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

export function calculateUpcomingOccurrences(
  subscriptions: Subscription[],
  referenceDate: Date = new Date(),
  daysForward: number = 60
): UpcomingOccurrence[] {
  const occurrences: UpcomingOccurrence[] = [];
  const refTime = new Date(referenceDate.getFullYear(), referenceDate.getMonth(), referenceDate.getDate()).getTime();

  subscriptions.forEach((sub) => {
    if (sub.status === 'paused') return;
    const start = new Date(sub.startDate);
    let due = new Date(start);

    const cycle = (sub.cycle || 'Monthly').toLowerCase();
    while (due.getTime() < refTime) {
      if (cycle === 'weekly') {
        due.setDate(due.getDate() + 7);
      } else if (cycle === 'yearly' || cycle === 'annual' || cycle === 'annually') {
        due.setFullYear(due.getFullYear() + 1);
      } else {
        due.setMonth(due.getMonth() + 1);
      }
    }

    const diffDays = Math.round((due.getTime() - refTime) / (1000 * 60 * 60 * 24));
    if (diffDays <= daysForward) {
      occurrences.push({
        subscription: sub,
        dueDate: due,
        daysRemaining: diffDays,
        formattedDate: due.toLocaleDateString('en-US', { day: 'numeric', month: 'short' })
      });
    }
  });

  return occurrences.sort((a, b) => a.daysRemaining - b.daysRemaining);
}
