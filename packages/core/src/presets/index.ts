import { PresetCatalogItem } from '../types';
import { fetchLogo } from '../utils/logo';
import { COMPLETE_SUBSCRIPTION_CATALOG, CatalogService, searchPresetCatalog } from './catalog';

export * from './catalog';

export interface RegionalPreset {
  name: string;
  amount: number;
  currencySymbol: string;
  currencyCode: string;
  category: string;
  cycle: string;
  logoUrl?: string;
  domain?: string;
}

export function getRegionalPresets(countryCode: string = 'FR'): RegionalPreset[] {
  const code = (countryCode || 'FR').toUpperCase().trim();
  const services = searchPresetCatalog('', code);

  return services.map((item) => ({
    name: item.name,
    amount: item.defaultAmount,
    currencySymbol: item.currencySymbol,
    currencyCode: item.currency,
    category: item.category,
    cycle: item.defaultCycle,
    domain: item.domain,
    logoUrl: fetchLogo(item.name)
  }));
}

export const REGIONAL_PRESETS: Record<string, RegionalPreset[]> = {
  FR: getRegionalPresets('FR'),
  US: getRegionalPresets('US'),
  GB: getRegionalPresets('GB'),
  DE: getRegionalPresets('DE'),
  ES: getRegionalPresets('ES'),
  IT: getRegionalPresets('IT')
};

export function detectUserCountry(): string {
  if (typeof window === 'undefined') return 'FR';
  try {
    const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
    if (tz.includes('Paris') || tz.includes('Europe/Paris')) return 'FR';
    if (tz.includes('London') || tz.includes('Europe/London')) return 'GB';
    if (tz.includes('America/New_York') || tz.includes('America/Los_Angeles') || tz.includes('America/Chicago')) return 'US';
    if (tz.includes('Berlin')) return 'DE';
    if (tz.includes('Madrid')) return 'ES';
    if (tz.includes('Rome')) return 'IT';
    
    const lang = (navigator.language || '').toLowerCase();
    if (lang.startsWith('fr')) return 'FR';
    if (lang === 'en-gb') return 'GB';
    if (lang.startsWith('en')) return 'US';
    if (lang.startsWith('de')) return 'DE';
    if (lang.startsWith('es')) return 'ES';
    if (lang.startsWith('it')) return 'IT';
  } catch (_) {}
  return 'FR';
}

export function getCurrencyForCountry(countryCode: string = 'FR'): { symbol: string; code: string } {
  switch (countryCode.toUpperCase()) {
    case 'US':
      return { symbol: '$', code: 'USD' };
    case 'GB':
      return { symbol: '£', code: 'GBP' };
    default:
      return { symbol: '€', code: 'EUR' };
  }
}

export const PRESET_SUBSCRIPTIONS: RegionalPreset[] = getRegionalPresets('FR');
