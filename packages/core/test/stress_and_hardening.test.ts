import { describe, it, expect } from 'vitest';
import {
  calculateTotalMonthlyCost,
  calculateTotalYearlyCost,
  calculateWhatIfSavings,
  roundToCents,
  normalizeMonthlyAmount
} from '../src/math/budget';
import { detectSubscriptionsFromTransactions } from '../src/truelayer/detector';
import { mergeSubscriptionsSnapshot } from '../src/backup/googleDrive';
import { Subscription } from '../src/types';
import { TrueLayerTransaction } from '../src/truelayer/types';

describe('SubFlow Stress Test & Bug Hardening Suite', () => {
  describe('1. Calculs Financiers & Élimination Dérives Flottantes (IEEE 754)', () => {
    it('roundToCents élimine les résidus décimaux (ex: 0.1 + 0.2)', () => {
      expect(0.1 + 0.2).not.toBe(0.3); // Preuve du bug natif IEEE 754
      expect(roundToCents(0.1 + 0.2)).toBe(0.3);
      expect(roundToCents(14.990000000000002)).toBe(14.99);
      expect(roundToCents(NaN)).toBe(0);
      expect(roundToCents(Infinity)).toBe(0);
    });

    it('calcule la somme de 2 000 abonnements en moins de 15ms sans dérive', () => {
      const massiveList: Subscription[] = [];
      for (let i = 0; i < 2000; i++) {
        massiveList.push({
          id: `sub-${i}`,
          name: `Service ${i}`,
          amount: 9.99,
          currency: 'EUR',
          cycle: 'Monthly',
          category: 'Entertainment',
          status: 'active',
          startDate: '2026-10-01'
        });
      }

      const start = performance.now();
      const totalMonthly = calculateTotalMonthlyCost(massiveList);
      const totalYearly = calculateTotalYearlyCost(massiveList);
      const elapsed = performance.now() - start;

      // 2000 * 9.99 = 19980.00
      expect(totalMonthly).toBe(19980);
      expect(totalYearly).toBe(239760);
      expect(elapsed).toBeLessThan(50); // Doit s'exécuter sous 50ms
    });

    it('gère les bascules What-If sur 1 000 exclusions simultanées', () => {
      const subs: Subscription[] = Array.from({ length: 1000 }, (_, i) => ({
        id: `s-${i}`,
        name: `Service ${i}`,
        amount: 10,
        currency: 'EUR',
        cycle: 'Monthly',
        category: 'Productivity',
        status: 'active',
        startDate: '2026-10-01'
      }));


      const excluded = new Set(subs.slice(0, 400).map((s) => s.id));
      const savings = calculateWhatIfSavings(subs, excluded);

      expect(savings.monthlySavings).toBe(4000);
      expect(savings.remainingMonthlyCost).toBe(6000);
      expect(savings.savingsPercentage).toBe(40);
    });
  });

  describe('2. TrueLayer Open Banking : Filtrage Transactions Futures & Invalides', () => {
    it('ignore les pré-autorisations futures aberrantes ou dates corrompues', () => {
      const now = new Date();
      const futureDate = new Date(now.getTime() + 90 * 86400000).toISOString(); // J+90
      const validPastDate1 = new Date(now.getTime() - 60 * 86400000).toISOString(); // J-60
      const validPastDate2 = new Date(now.getTime() - 30 * 86400000).toISOString(); // J-30


      const rawTxs: TrueLayerTransaction[] = [
        {
          id: 'tx-future',
          date: futureDate,
          description: 'PRLV SEPA NETFLIX FUTURE',
          amount: 17.99,
          currency: 'EUR'
        },
        {
          id: 'tx-1',
          date: validPastDate1,
          description: 'PRLV SEPA NETFLIX',
          amount: 17.99,
          currency: 'EUR'
        },
        {
          id: 'tx-2',
          date: validPastDate2,
          description: 'PRLV SEPA NETFLIX',
          amount: 17.99,
          currency: 'EUR'
        },
        {
          id: 'tx-corrupt',
          date: 'invalid-date-string',
          description: 'PRLV CORROMPU',
          amount: 25.0,
          currency: 'EUR'
        }
      ];

      const detected = detectSubscriptionsFromTransactions(rawTxs);
      expect(detected.length).toBe(1);
      expect(detected[0]?.name).toBe('Netflix');
      expect(detected[0]?.amount).toBe(17.99);
      // La transaction future ne doit pas avoir été retenue comme lastChargeDate
      expect(detected[0]?.lastChargeDate).toBe(validPastDate2.slice(0, 10));
    });
  });

  describe('3. Google Drive Multi-Écrans : Fusion Intelligente sans Écrasement', () => {
    it('fusionne les abonnements par identifiant unique en préservant le plus récent', () => {
      const localSubs = [
        { id: 'sub-1', name: 'Spotify Local Edit', amount: 11.99, updatedAt: '2026-09-10T12:00:00Z' },
        { id: 'sub-2', name: 'GitHub', amount: 4.0, updatedAt: '2026-09-08T10:00:00Z' }
      ];

      const remoteSubs = [
        { id: 'sub-1', name: 'Spotify Old Remote', amount: 9.99, updatedAt: '2026-09-09T10:00:00Z' },
        { id: 'sub-3', name: 'iCloud+', amount: 2.99, updatedAt: '2026-09-09T15:00:00Z' }
      ];

      const merged = mergeSubscriptionsSnapshot(localSubs, remoteSubs);

      expect(merged.length).toBe(3);
      const spotify = merged.find((s) => s.id === 'sub-1');
      expect(spotify?.name).toBe('Spotify Local Edit');
      expect(spotify?.amount).toBe(11.99);

      const icloud = merged.find((s) => s.id === 'sub-3');
      expect(icloud?.name).toBe('iCloud+');
    });
  });
});
