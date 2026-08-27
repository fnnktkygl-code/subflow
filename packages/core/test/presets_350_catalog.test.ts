import { describe, it, expect } from 'vitest';
import {
  COMPLETE_SUBSCRIPTION_CATALOG,
  searchPresetCatalog,
  getRegionalPresets,
  getCancellationGuide
} from '../src';

describe('350+ Comprehensive Subscription Catalog Engine', () => {
  it('contains over 350 high-quality subscription presets', () => {
    expect(COMPLETE_SUBSCRIPTION_CATALOG.length).toBeGreaterThanOrEqual(350);
  });

  it('validates that every subscription in the 350+ catalog has valid properties', () => {
    for (const item of COMPLETE_SUBSCRIPTION_CATALOG) {
      expect(item.id).toBeTruthy();
      expect(item.name.trim().length).toBeGreaterThan(0);
      expect(item.defaultAmount).toBeGreaterThan(0);
      expect(item.category).toBeTruthy();
      expect(item.currency).toBeTruthy();
      expect(item.currencySymbol).toBeTruthy();
      expect(item.domain).toBeTruthy();
      expect(item.popularIn.length).toBeGreaterThan(0);
      expect(['Monthly', 'Yearly', 'Weekly']).toContain(item.defaultCycle);
    }
  });

  it('covers all core subscription categories with depth', () => {
    const categories = new Set(COMPLETE_SUBSCRIPTION_CATALOG.map((i) => i.category));
    expect(categories.has('Entertainment')).toBe(true);
    expect(categories.has('Productivity')).toBe(true);
    expect(categories.has('Utilities')).toBe(true);
    expect(categories.has('Health & Fitness')).toBe(true);
    expect(categories.has('Shopping')).toBe(true);
    expect(categories.has('Food & Dining')).toBe(true);
  });

  it('searches correctly across 350+ services with fuzzy keywords', () => {
    const streamingResults = searchPresetCatalog('netflix');
    expect(streamingResults.some((s) => s.name === 'Netflix')).toBe(true);

    const aiResults = searchPresetCatalog('claude');
    expect(aiResults.some((s) => s.name.includes('Claude'))).toBe(true);

    const telecomResults = searchPresetCatalog('freebox');
    expect(telecomResults.some((s) => s.name.includes('Freebox'))).toBe(true);

    const pressResults = searchPresetCatalog('monde');
    expect(pressResults.some((s) => s.name.includes('Le Monde'))).toBe(true);

    const gymResults = searchPresetCatalog('fitness');
    expect(gymResults.length).toBeGreaterThanOrEqual(3);
  });

  it('filters by category accurately', () => {
    const healthSubs = searchPresetCatalog('', 'FR', 'Health & Fitness');
    expect(healthSubs.length).toBeGreaterThanOrEqual(15);
    for (const sub of healthSubs) {
      expect(sub.category).toBe('Health & Fitness');
    }
  });

  it('connects 350+ services to the 1-click cancellation assistant', () => {
    const guideClaude = getCancellationGuide('Claude Pro (Anthropic)');
    expect(guideClaude).toBeDefined();
    expect(guideClaude?.directCancelUrl).toContain('claude.ai');

    const guideFreebox = getCancellationGuide('Freebox Pop Fibre');
    expect(guideFreebox).toBeDefined();
    expect(guideFreebox?.directCancelUrl).toContain('free.fr');
  });
});
