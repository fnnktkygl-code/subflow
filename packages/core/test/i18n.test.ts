import { describe, it, expect } from 'vitest';
import { fr, en, t, formatCurrency, detectUserLanguage } from '../src';

function getAllKeys(obj: Record<string, any>, prefix = ''): string[] {
  return Object.keys(obj).reduce((res: string[], el: string) => {
    if (Array.isArray(obj[el])) {
      return res;
    } else if (typeof obj[el] === 'object' && obj[el] !== null) {
      return [...res, ...getAllKeys(obj[el], `${prefix}${el}.`)];
    }
    return [...res, `${prefix}${el}`];
  }, []);
}

describe('i18n & Multi-Currency System Engine', () => {
  it('guarantees 100% key parity between French and English locales', () => {
    const frKeys = getAllKeys(fr).sort();
    const enKeys = getAllKeys(en).sort();

    expect(frKeys).toEqual(enKeys);
    expect(frKeys.length).toBeGreaterThan(50);
  });

  it('translates nested keys correctly in French and English', () => {
    expect(t('nav.home', 'fr')).toBe('Accueil');
    expect(t('nav.home', 'en')).toBe('Home');

    expect(t('subs.addSubscription', 'fr')).toBe('Ajouter un abonnement');
    expect(t('subs.addSubscription', 'en')).toBe('Add Subscription');

    expect(t('common.save', 'fr')).toBe('Enregistrer');
    expect(t('common.save', 'en')).toBe('Save');
  });

  it('interpolates parameters seamlessly', () => {
    expect(t('home.activeCount', 'fr', { count: 5 })).toBe('5 abonnements actifs');
    expect(t('home.activeCount', 'en', { count: 5 })).toBe('5 active subscriptions');

    expect(t('subs.deleteConfirmMessage', 'fr', { name: 'Netflix' })).toBe(
      'Cette action retirera définitivement "Netflix" de votre budget SubFlow.'
    );
    expect(t('subs.deleteConfirmMessage', 'en', { name: 'Netflix' })).toBe(
      'This will permanently remove "Netflix" from your SubFlow budget.'
    );
  });

  it('formats multi-currency amounts properly across locales', () => {
    expect(formatCurrency(49.99, 'EUR', '€', 'fr')).toContain('49,99');
    expect(formatCurrency(49.99, 'EUR', '€', 'en')).toContain('49.99');

    expect(formatCurrency(19.99, 'USD', '$', 'en')).toBe('$19.99');
    expect(formatCurrency(12.5, 'GBP', '£', 'en')).toBe('£12.50');
  });

  it('falls back safely to key or English when a key is missing', () => {
    expect(t('nonexistent.key', 'fr')).toBe('nonexistent.key');
  });
});
