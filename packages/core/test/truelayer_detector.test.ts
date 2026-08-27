import { describe, it, expect } from 'vitest';
import {
  cleanTransactionDescription,
  findMatchingCatalogItem,
  detectSubscriptionsFromTransactions,
  getMockFrenchBankTransactions
} from '../src/truelayer/detector';

describe('TrueLayer Subscription Detector & Open Banking Engine', () => {
  describe('cleanTransactionDescription', () => {
    it('strips French SEPA direct debit prefixes cleanly', () => {
      expect(cleanTransactionDescription('PRLV SEPA NETFLIX SERVICES FRANCE')).toBe('Netflix');
      expect(cleanTransactionDescription('PRELEVEMENT SEPA FREE TELECOM FACTURE 876543')).toBe('Free Telecom');
      expect(cleanTransactionDescription('PRLV BASIC-FIT FRANCE II SARL')).toBe('Basic Fit Ii');
    });

    it('strips CB card payment prefixes and transaction codes', () => {
      expect(cleanTransactionDescription('CB SPOTIFY COM PREMIUM REF 12345')).toBe('Spotify Premium');
      expect(cleanTransactionDescription('PAIEMENT CB OPENAI *CHATGPT')).toBe('Openai Chatgpt');
    });
  });

  describe('findMatchingCatalogItem', () => {
    it('matches known services in the 365+ preset catalog', () => {
      const netflix = findMatchingCatalogItem('Netflix');
      expect(netflix).toBeDefined();
      expect(netflix?.name).toBe('Netflix');
      expect(netflix?.cancellationUrl).toBeDefined();

      const spotify = findMatchingCatalogItem('Spotify');
      expect(spotify).toBeDefined();
      expect(spotify?.category).toBe('Entertainment');

      const chatgpt = findMatchingCatalogItem('ChatGPT');
      expect(chatgpt).toBeDefined();
    });
  });

  describe('detectSubscriptionsFromTransactions', () => {
    it('correctly detects recurring subscriptions from realistic mock bank statement', () => {
      const transactions = getMockFrenchBankTransactions();
      const detected = detectSubscriptionsFromTransactions(transactions, {
        currency: 'EUR',
        currencySymbol: '€'
      });

      expect(detected.length).toBeGreaterThanOrEqual(4);

      // Verify Netflix detected
      const netflixSub = detected.find((s) => s.name.toLowerCase().includes('netflix'));
      expect(netflixSub).toBeDefined();
      expect(netflixSub?.amount).toBe(13.49);
      expect(netflixSub?.cycle).toBe('monthly');
      expect(netflixSub?.confidence).toBe('high');
      expect(netflixSub?.occurrencesCount).toBe(3);
      expect(netflixSub?.matchedCatalogItem?.cancellationUrl).toBeDefined();

      // Verify Spotify detected
      const spotifySub = detected.find((s) => s.name.toLowerCase().includes('spotify'));
      expect(spotifySub).toBeDefined();
      expect(spotifySub?.amount).toBe(10.99);
      expect(spotifySub?.cycle).toBe('monthly');
      expect(spotifySub?.confidence).toBe('high');

      // Verify Free detected
      const freeSub = detected.find((s) => s.name.toLowerCase().includes('free'));
      expect(freeSub).toBeDefined();
      expect(freeSub?.amount).toBe(29.99);

      // Verify Basic-Fit detected
      const fitSub = detected.find((s) => s.name.toLowerCase().includes('basic'));
      expect(fitSub).toBeDefined();
      expect(fitSub?.amount).toBe(29.99);

      // Verify One-off expenses (Carrefour, Restaurant, SNCF) were NOT falsely detected as subscriptions
      const carrefour = detected.find((s) => s.name.toLowerCase().includes('carrefour'));
      expect(carrefour).toBeUndefined();

      const resto = detected.find((s) => s.name.toLowerCase().includes('bistrot'));
      expect(resto).toBeUndefined();

      const sncf = detected.find((s) => s.name.toLowerCase().includes('sncf'));
      expect(sncf).toBeUndefined();
    });
  });
});
