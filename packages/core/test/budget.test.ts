import { describe, it, expect } from 'vitest';
import {
  normalizeMonthlyAmount,
  calculateTotalMonthlyCost,
  calculateWhatIfSavings,
  calculate503020Split,
  calculateCategoryBreakdown,
  calculateUpcomingOccurrences,
  formatCurrency
} from '../src/math/budget';
import { Subscription } from '../src/types';

describe('1. Financial Core Math & Normalization', () => {
  it('normalizes Monthly cycles with exact precision', () => {
    expect(normalizeMonthlyAmount(15.99, 'Monthly')).toBe(15.99);
    expect(normalizeMonthlyAmount(0, 'Monthly')).toBe(0);
  });

  it('normalizes Yearly / Annual cycles to 12 months', () => {
    expect(normalizeMonthlyAmount(120, 'Yearly')).toBe(10);
    expect(normalizeMonthlyAmount(99.99, 'Yearly')).toBeCloseTo(8.3325, 3);
    expect(normalizeMonthlyAmount(60, 'Annually')).toBe(5);
    expect(normalizeMonthlyAmount(120, 'Annual')).toBe(10);
  });

  it('normalizes Quarterly cycles to 3 months', () => {
    expect(normalizeMonthlyAmount(30, 'Quarterly')).toBe(10);
    expect(normalizeMonthlyAmount(45, 'Quarterly')).toBe(15);
  });

  it('normalizes Semi-Annual cycles to 6 months', () => {
    expect(normalizeMonthlyAmount(60, 'Semi-Annual')).toBe(10);
    expect(normalizeMonthlyAmount(120, 'Semi-Annually')).toBe(20);
  });

  it('normalizes Weekly cycles to monthly average (52 weeks / 12 months = 4.333x)', () => {
    expect(normalizeMonthlyAmount(10, 'Weekly')).toBeCloseTo(43.333, 2);
    expect(normalizeMonthlyAmount(2.5, 'Weekly')).toBeCloseTo(10.833, 2);
  });

  it('normalizes Bi-Weekly / Fortnightly cycles (26 pay periods / 12 months)', () => {
    expect(normalizeMonthlyAmount(20, 'Bi-Weekly')).toBeCloseTo(43.333, 2);
  });

  it('normalizes Daily cycles to 365 / 12 days', () => {
    expect(normalizeMonthlyAmount(1, 'Daily')).toBeCloseTo(30.416, 2);
  });

  it('handles zero, negative or NaN amounts safely without crashing', () => {
    expect(normalizeMonthlyAmount(0, 'Monthly')).toBe(0);
    expect(normalizeMonthlyAmount(-10, 'Monthly')).toBe(0);
    expect(normalizeMonthlyAmount(NaN, 'Monthly')).toBe(0);
  });
});

describe('2. Total Monthly Cost & Exclusion Engine', () => {
  const sampleSubs: Subscription[] = [
    { id: 'sub-1', name: 'Netflix', amount: 13.49, category: 'Entertainment', cycle: 'Monthly', startDate: '2026-08-01' },
    { id: 'sub-2', name: 'Spotify', amount: 10.99, category: 'Entertainment', cycle: 'Monthly', startDate: '2026-08-01' },
    { id: 'sub-3', name: 'Gym', amount: 360, category: 'Health & Fitness', cycle: 'Yearly', startDate: '2026-08-01' },
    { id: 'sub-4', name: 'Paused App', amount: 15, category: 'Utilities', cycle: 'Monthly', startDate: '2026-08-01', status: 'paused' }
  ];

  it('calculates total monthly commitments accurately excluding paused subscriptions', () => {
    // 13.49 + 10.99 + 30 (gym) = 54.48 (paused app 15 is ignored)
    expect(calculateTotalMonthlyCost(sampleSubs)).toBeCloseTo(54.48, 2);
  });

  it('calculates total monthly commitments with active excludedIds', () => {
    // Exclude gym (30/mo) -> 13.49 + 10.99 = 24.48
    expect(calculateTotalMonthlyCost(sampleSubs, new Set(['sub-3']))).toBeCloseTo(24.48, 2);
  });

  it('returns 0 when all subscriptions are excluded or list is empty', () => {
    expect(calculateTotalMonthlyCost([])).toBe(0);
    expect(calculateTotalMonthlyCost(sampleSubs, new Set(['sub-1', 'sub-2', 'sub-3', 'sub-4']))).toBe(0);
  });
});

describe('3. What-If Simulation Engine', () => {
  const sampleSubs: Subscription[] = [
    { id: '1', name: 'Netflix', amount: 20, category: 'Entertainment', cycle: 'Monthly', startDate: '2026-08-01' },
    { id: '2', name: 'Spotify', amount: 10, category: 'Entertainment', cycle: 'Monthly', startDate: '2026-08-01' },
    { id: '3', name: 'Gym', amount: 30, category: 'Health & Fitness', cycle: 'Monthly', startDate: '2026-08-01' }
  ];

  it('computes correct monthly and yearly savings when cards are excluded', () => {
    const savings = calculateWhatIfSavings(sampleSubs, new Set(['1', '3'])); // Exclude Netflix (20) and Gym (30) = 50/mo
    expect(savings.monthlySavings).toBe(50);
    expect(savings.yearlySavings).toBe(600);
    expect(savings.excludedCount).toBe(2);
    expect(savings.totalCount).toBe(3);
    expect(savings.remainingMonthlyCost).toBe(10);
    expect(savings.savingsPercentage).toBeCloseTo(83.33, 1);
  });

  it('handles 0 exclusions gracefully', () => {
    const savings = calculateWhatIfSavings(sampleSubs, new Set());
    expect(savings.monthlySavings).toBe(0);
    expect(savings.yearlySavings).toBe(0);
    expect(savings.excludedCount).toBe(0);
    expect(savings.totalCount).toBe(3);
    expect(savings.remainingMonthlyCost).toBe(60);
    expect(savings.savingsPercentage).toBe(0);
  });

  it('handles 100% exclusions gracefully', () => {
    const savings = calculateWhatIfSavings(sampleSubs, new Set(['1', '2', '3']));
    expect(savings.monthlySavings).toBe(60);
    expect(savings.yearlySavings).toBe(720);
    expect(savings.excludedCount).toBe(3);
    expect(savings.totalCount).toBe(3);
    expect(savings.remainingMonthlyCost).toBe(0);
    expect(savings.savingsPercentage).toBe(100);
  });
});

describe('4. 50/30/20 Financial Framework Splits', () => {
  it('correctly divides monthly income into 50% Needs, 30% Wants, 20% Savings', () => {
    const split = calculate503020Split(4000, 200);
    expect(split.needsTarget).toBe(2000);
    expect(split.wantsTarget).toBe(1200);
    expect(split.savingsTarget).toBe(800);
    expect(split.freeCashFlowRemaining).toBe(3800);
    expect(split.subscriptionsPercentageOfIncome).toBe(5);
    expect(split.isBudgetHealthy).toBe(true);
    expect(split.healthStatus).toBe('optimal');
  });

  it('flags warning status when subscriptions exceed 15% of income', () => {
    const split = calculate503020Split(1000, 200); // 20% of income
    expect(split.subscriptionsPercentageOfIncome).toBe(20);
    expect(split.isBudgetHealthy).toBe(false);
    expect(split.healthStatus).toBe('warning');
  });

  it('flags critical status when subscriptions exceed 30% of income', () => {
    const split = calculate503020Split(1000, 350); // 35% of income
    expect(split.subscriptionsPercentageOfIncome).toBe(35);
    expect(split.isBudgetHealthy).toBe(false);
    expect(split.healthStatus).toBe('critical');
  });

  it('handles 0 or negative income without dividing by zero', () => {
    const split = calculate503020Split(0, 100);
    expect(split.needsTarget).toBe(0);
    expect(split.subscriptionsPercentageOfIncome).toBe(0);
    expect(split.isBudgetHealthy).toBe(false);
  });
});

describe('5. Category Breakdown Aggregation', () => {
  const subs: Subscription[] = [
    { id: '1', name: 'Netflix', amount: 15, category: 'Entertainment', cycle: 'Monthly', startDate: '2026-08-01' },
    { id: '2', name: 'Spotify', amount: 10, category: 'Entertainment', cycle: 'Monthly', startDate: '2026-08-01' },
    { id: '3', name: 'ChatGPT', amount: 25, category: 'Productivity', cycle: 'Monthly', startDate: '2026-08-01' }
  ];

  it('aggregates total spend and percentage by category', () => {
    const breakdown = calculateCategoryBreakdown(subs);
    expect(breakdown['Entertainment']?.total).toBe(25);
    expect(breakdown['Entertainment']?.count).toBe(2);
    expect(breakdown['Entertainment']?.percentage).toBe(50);

    expect(breakdown['Productivity']?.total).toBe(25);
    expect(breakdown['Productivity']?.count).toBe(1);
    expect(breakdown['Productivity']?.percentage).toBe(50);
  });

  it('recalculates percentages dynamically when categories are excluded', () => {
    const breakdown = calculateCategoryBreakdown(subs, new Set(['3']));
    expect(breakdown['Entertainment']?.total).toBe(25);
    expect(breakdown['Entertainment']?.percentage).toBe(100);
    expect(breakdown['Productivity']).toBeUndefined();
  });
});

describe('6. Upcoming Occurrences & Renewal Schedule', () => {
  const subs: Subscription[] = [
    { id: '1', name: 'Netflix', amount: 13.49, category: 'Entertainment', cycle: 'Monthly', startDate: '2026-08-27' },
    { id: '2', name: 'Spotify', amount: 10.99, category: 'Entertainment', cycle: 'Monthly', startDate: '2026-08-15' }
  ];

  it('identifies renewals occurring today (daysRemaining === 0)', () => {
    const refDate = new Date(2026, 7, 27); // Aug 27, 2026
    const occurrences = calculateUpcomingOccurrences(subs, refDate, 30);
    const todayOcc = occurrences.find((o) => o.subscription.id === '1');
    expect(todayOcc).toBeDefined();
    expect(todayOcc?.daysRemaining).toBe(0);
  });

  it('rolls forward past dates to the next recurring cycle', () => {
    const refDate = new Date(2026, 7, 27); // Aug 27, 2026
    const occurrences = calculateUpcomingOccurrences(subs, refDate, 30);
    const spotifyOcc = occurrences.find((o) => o.subscription.id === '2');
    expect(spotifyOcc).toBeDefined();
    // Aug 15 was in the past, so next due date is Sep 15 (19 days from Aug 27)
    expect(spotifyOcc?.dueDate.getMonth()).toBe(8); // September
    expect(spotifyOcc?.dueDate.getDate()).toBe(15);
    expect(spotifyOcc?.daysRemaining).toBe(19);
  });
});

describe('7. Currency Formatting', () => {
  it('formats amounts with 2 decimals and given currency symbol', () => {
    expect(formatCurrency(48.48, '€')).toBe('€48.48');
    expect(formatCurrency(120, '$')).toBe('$120.00');
    expect(formatCurrency(0, '£')).toBe('£0.00');
  });
});
