import { fr } from './locales/fr';
import { en } from './locales/en';

export type Locale = 'fr' | 'en';

export const LOCALES: Record<Locale, typeof fr> = {
  fr,
  en
};

export type NestedKeyOf<ObjectType extends object> = {
  [Key in keyof ObjectType & (string | number)]: ObjectType[Key] extends object
    ? `${Key}` | `${Key}.${NestedKeyOf<ObjectType[Key]>}`
    : `${Key}`;
}[keyof ObjectType & (string | number)];

export type TranslationKey = NestedKeyOf<typeof fr>;

export function t(
  key: string,
  locale: Locale = 'fr',
  params?: Record<string, string | number>
): string {
  const activeLocale = LOCALES[locale] || LOCALES.fr;
  const parts = key.split('.');

  let current: any = activeLocale;
  for (const part of parts) {
    if (current && typeof current === 'object' && part in current) {
      current = current[part];
    } else {
      // Fallback to English, then to key
      const fallbackLocale = LOCALES.en;
      let fbCurrent: any = fallbackLocale;
      for (const fbPart of parts) {
        if (fbCurrent && typeof fbCurrent === 'object' && fbPart in fbCurrent) {
          fbCurrent = fbCurrent[fbPart];
        } else {
          fbCurrent = key;
          break;
        }
      }
      current = fbCurrent;
      break;
    }
  }

  if (typeof current !== 'string') {
    return key;
  }

  if (params) {
    return Object.entries(params).reduce((str, [paramKey, paramValue]) => {
      return str.replace(new RegExp(`\\{${paramKey}\\}`, 'g'), String(paramValue));
    }, current);
  }

  return current;
}

export function detectUserLanguage(): Locale {
  if (typeof window === 'undefined') return 'fr';
  try {
    const lang = (navigator.language || navigator.languages?.[0] || '').toLowerCase();
    if (lang.startsWith('fr')) return 'fr';
    return 'en';
  } catch (_) {
    return 'fr';
  }
}

export function formatCurrency(
  amount: number,
  currencyCodeOrSymbol: string = 'EUR',
  currencySymbol?: string,
  locale?: Locale
): string {
  const safeAmount = isNaN(amount) ? 0 : amount;
  const numStr = safeAmount.toFixed(2);

  // If called as formatCurrency(amount, '€')
  if (currencyCodeOrSymbol && currencyCodeOrSymbol.length <= 2 && !currencySymbol && !locale) {
    return `${currencyCodeOrSymbol}${numStr}`;
  }

  const code = currencyCodeOrSymbol || 'EUR';
  const symbol = currencySymbol || (code === 'EUR' ? '€' : code === 'USD' || code === 'CAD' ? '$' : code === 'GBP' ? '£' : '€');

  if (locale === 'fr' && (code === 'EUR' || symbol === '€')) {
    return `${numStr.replace('.', ',')} €`;
  }
  return `${symbol}${numStr}`;
}

export { fr, en };
