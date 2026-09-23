import { fr } from './locales/fr';
import { en } from './locales/en';
import { es } from './locales/es';

export type Locale = 'fr' | 'en' | 'es';

export const LOCALES: Record<Locale, typeof fr> = {
  fr,
  en,
  es
};

/** BCP 47 tag used for dates and numbers. */
export const LOCALE_TAG: Record<Locale, string> = { fr: 'fr-FR', en: 'en-US', es: 'es-ES' };
export const LOCALE_NAMES: Record<Locale, string> = { fr: 'Français', en: 'English', es: 'Español' };
export const isLocale = (v: unknown): v is Locale => v === 'fr' || v === 'en' || v === 'es';

/** Picks the text for a locale: { fr, en, es } (es falls back to en). */
export function pick<T>(locale: Locale | string | undefined, texts: { fr: T; en: T; es?: T }): T {
  return locale === 'fr' ? texts.fr : locale === 'es' ? (texts.es ?? texts.en) : texts.en;
}

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
    if (lang.startsWith('es')) return 'es';
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

  if (isLocale(symbolOrLocale)) {
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

  const formattedNum = safeAmount.toLocaleString(LOCALE_TAG[locale] || 'fr-FR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  });

  if (locale === 'fr' || locale === 'es') {
    return `${formattedNum} ${symbol}`;
  }
  return `${symbol}${formattedNum}`;
}

export { fr, en, es };
