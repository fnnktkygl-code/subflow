import { describe, it, expect } from 'vitest';
import { calculateUpcomingOccurrences, calculateNextRenewalDate, calculateTotalYearlyCost } from '../src/math/budget';
import { exportSubscriptionsToCSV, parseSubscriptionsFromCSV } from '../src/backup/csv';
import { Subscription } from '../src/types';
const sub = (overrides: Partial<Subscription> = {}): Subscription => ({ id: 'test', name: 'Service', amount: 10, cycle: 'Monthly', category: 'General', startDate: '2024-01-31', ...overrides });
describe('Release: calendar, imports and stress', () => {
  it('keeps the 31st anchor after February and handles leap years', () => {
    expect(calculateUpcomingOccurrences([sub()], new Date(2024, 1, 1))[0]?.dueDate.getDate()).toBe(29);
    expect(calculateUpcomingOccurrences([sub()], new Date(2024, 2, 1))[0]?.dueDate.getDate()).toBe(31);
    expect(calculateNextRenewalDate('2024-02-29', 'Yearly', new Date(2025, 1, 1))).toBe('2025-02-28');
  });
  it.each([['Daily','2026-09-13'], ['Weekly','2026-09-19'], ['Bi-Weekly','2026-09-26'], ['Quarterly','2026-12-12'], ['Semi-Annual','2027-03-12']])('supports %s without monthly fallback', (cycle, expected) => {
    expect(calculateNextRenewalDate('2026-09-12', cycle, new Date(2026, 8, 13))).toBe(expected);
  });
  it('skips invalid dates and paused payments, includes today', () => {
    const result = calculateUpcomingOccurrences([sub({startDate:'2026-09-12'}), sub({id:'bad', startDate:'2026-02-31'}), sub({id:'paused',status:'paused'})], new Date(2026,8,12));
    expect(result.map(x => x.subscription.id)).toEqual(['test']);
    expect(result[0]?.daysRemaining).toBe(0);
  });
  it('annualization does not multiply a rounded monthly amount', () => {
    expect(calculateTotalYearlyCost([sub({amount: 100, cycle: 'Yearly'})])).toBe(100);
  });
  it('round trips multiline notes, comma names, currency and paused status', () => {
    const data = sub({name:'Cloud, family', notes:'Line 1\n"Line 2"', currency:'USD',status:'paused'});
    expect(parseSubscriptionsFromCSV(exportSubscriptionsToCSV([data]))[0]).toMatchObject({name:data.name,notes:data.notes,currency:'USD',status:'paused',amount:10});
  });
  it('neutralizes spreadsheet formulas and rejects negatives instead of converting them', () => {
    expect(exportSubscriptionsToCSV([sub({name:'=1+1'})])).toContain("'=1+1");
    expect(() => parseSubscriptionsFromCSV('Name,Amount\nTest,-10')).toThrow();
  });
  it('calculates 10,000 decades-old recurrences without iterating through every month', () => {
    const list = Array.from({length:10000}, (_,i) => sub({id:String(i),startDate:'1900-01-31'}));
    const start = performance.now();
    const results = calculateUpcomingOccurrences(list, new Date(2026,8,12));
    const ms = performance.now() - start;
    expect(results).toHaveLength(10000);
    expect(results.every(x => x.daysRemaining === 18)).toBe(true);
    console.info(`10,000 calendar recurrences: ${Math.round(ms)} ms`);
    expect(ms).toBeLessThan(3000);
  });
});
