import { describe, it, expect } from 'vitest';
import { subscriptionSchema, userProfileSchema } from '../src/validation/schemas';
import { extractDomain, getLogoSources, LOCAL_SVG_LOGOS } from '../src/utils/logo';
import { PRESET_SUBSCRIPTIONS } from '../src/presets';

describe('1. Zod Data Validation Schemas', () => {
  it('validates a correct subscription object', () => {
    const validSub = {
      id: 'sub-123',
      name: 'Netflix Premium',
      amount: 19.99,
      category: 'Entertainment',
      cycle: 'Monthly',
      startDate: '2026-08-27',
      currency: 'EUR'
    };

    const result = subscriptionSchema.safeParse(validSub);
    expect(result.success).toBe(true);
  });

  it('rejects invalid or negative subscription amounts', () => {
    const invalidSub = {
      id: 'sub-123',
      name: 'Netflix',
      amount: -10,
      category: 'Entertainment',
      cycle: 'Monthly',
      startDate: '2026-08-27'
    };

    const result = subscriptionSchema.safeParse(invalidSub);
    expect(result.success).toBe(false);
  });

  it('rejects missing mandatory fields', () => {
    const missingName = {
      id: 'sub-123',
      amount: 10,
      category: 'Entertainment',
      cycle: 'Monthly',
      startDate: '2026-08-27'
    };

    const result = subscriptionSchema.safeParse(missingName);
    expect(result.success).toBe(false);
  });

  it('validates user profile schema', () => {
    const validProfile = {
      name: 'Richard',
      monthlyIncome: 3500,
      monthlyTarget: 80,
      currencySymbol: '€',
      currency: 'EUR',
      theme: 'japandi-light'
    };

    const result = userProfileSchema.safeParse(validProfile);
    expect(result.success).toBe(true);
  });
});

describe('2. Brand Domain Extraction & Logo Resolver', () => {
  it('extracts known brand domains accurately', () => {
    expect(extractDomain('Netflix')).toBe('netflix.com');
    expect(extractDomain('Spotify')).toBe('spotify.com');
    expect(extractDomain('ChatGPT Plus')).toBe('openai.com');
    expect(extractDomain('Canal+')).toBe('canalplus.com');
    expect(extractDomain('Apple Music')).toBe('apple.com');
    expect(extractDomain('Amazon Prime')).toBe('amazon.com');
  });

  it('extracts domain from custom URL input', () => {
    expect(extractDomain('https://linear.app')).toBe('linear.app');
  });

  it('sanitizes input against special characters and XSS attempts', () => {
    expect(extractDomain('<script>alert(1)</script>')).not.toContain('<');
    expect(extractDomain('   ')).toBe('');
  });

  it('prioritizes local bundled SVGs when available', () => {
    const sources = getLogoSources('ChatGPT Plus');
    expect(sources[0]).toBe('/logos/chatgpt.svg');
  });

  it('provides multi-tier CDN fallback sequence for unknown brands', () => {
    const sources = getLogoSources('Custom Saas Tool');
    expect(sources.some((s) => s.includes('google.com/s2/favicons'))).toBe(true);
    expect(sources.some((s) => s.includes('unavatar.io'))).toBe(true);
    expect(sources.some((s) => s.includes('icon.horse'))).toBe(true);
  });
});

describe('3. Preset Subscriptions Catalog Integrity', () => {
  it('contains valid preset subscriptions', () => {
    expect(PRESET_SUBSCRIPTIONS.length).toBeGreaterThan(0);
  });

  it('ensures every preset passes subscription schema validation', () => {
    PRESET_SUBSCRIPTIONS.forEach((preset) => {
      const parsed = subscriptionSchema.safeParse({
        ...preset,
        id: `preset-${preset.name.toLowerCase().replace(/\s+/g, '-')}`,
        startDate: '2026-08-01'
      });
      expect(parsed.success).toBe(true);
    });
  });

  it('ensures every preset has a valid category and positive amount', () => {
    PRESET_SUBSCRIPTIONS.forEach((preset) => {
      expect(preset.amount).toBeGreaterThan(0);
      expect(preset.name.length).toBeGreaterThan(0);
      expect(preset.category.length).toBeGreaterThan(0);
    });
  });
});
