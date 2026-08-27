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
  symbolOrLocale?: string,
  explicitLocale?: Locale
): string {
  const safeAmount = isNaN(amount) ? 0 : amount;

  // Si appelé directement avec un symbole monétaire unique (ex: formatCurrency(48.48, '€') ou '$')
  if (
    currencyCodeOrSymbol &&
    currencyCodeOrSymbol.length <= 3 &&
    !symbolOrLocale &&
    !explicitLocale
  ) {
    if (['€', '$', '£', '¥', 'CHF', 'CA$', 'AU$'].includes(currencyCodeOrSymbol)) {
      return `${currencyCodeOrSymbol}${safeAmount.toFixed(2)}`;
    }
  }

  let locale: Locale = 'fr';
  let symbol = '€';
  let code = (currencyCodeOrSymbol || 'EUR').toUpperCase();

  if (symbolOrLocale === 'fr' || symbolOrLocale === 'en') {
    locale = symbolOrLocale;
  } else if (symbolOrLocale) {
    symbol = symbolOrLocale;
  }

  if (explicitLocale) {
    locale = explicitLocale;
  }

  if (code === 'EUR' || currencyCodeOrSymbol === '€') {
    symbol = '€';
    code = 'EUR';
  } else if (code === 'USD' || currencyCodeOrSymbol === '$') {
    symbol = '$';
    code = 'USD';
  } else if (code === 'GBP' || currencyCodeOrSymbol === '£') {
    symbol = '£';
    code = 'GBP';
  } else if (code === 'CAD' || currencyCodeOrSymbol === 'CA$') {
    symbol = 'CA$';
    code = 'CAD';
  } else if (code === 'CHF') {
    symbol = 'CHF';
  } else if (code === 'JPY' || currencyCodeOrSymbol === '¥') {
    symbol = '¥';
    code = 'JPY';
  }

  const formattedNum = safeAmount.toLocaleString(locale === 'fr' ? 'fr-FR' : 'en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  });

  if (locale === 'fr') {
    return `${formattedNum} ${symbol}`;
  }
  return `${symbol}${formattedNum}`;
}

export { fr, en };
