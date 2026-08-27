'use client';

import { useCallback } from 'react';
import { useSubscriptionStore } from '../store/useSubscriptionStore';
import { t as coreT, Locale, formatCurrency, TranslationKey } from '@subflow/core';

export function useTranslation() {
  const { profile, updateProfile } = useSubscriptionStore();
  const locale: Locale = profile.language === 'en' ? 'en' : 'fr';

  const t = useCallback(
    (key: string, params?: Record<string, string | number>): string => {
      return coreT(key, locale, params);
    },
    [locale]
  );

  const setLocale = useCallback(
    (newLocale: Locale) => {
      updateProfile({ language: newLocale });
    },
    [updateProfile]
  );

  const format = useCallback(
    (amount: number): string => {
      return formatCurrency(
        amount,
        profile.currency || 'EUR',
        profile.currencySymbol || '€',
        locale
      );
    },
    [profile.currency, profile.currencySymbol, locale]
  );

  return {
    t,
    locale,
    setLocale,
    format
  };
}
