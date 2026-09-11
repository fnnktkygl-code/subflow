import { describe, it, expect } from 'vitest';
import {
  NATIVE_SVG_ICONS,
  getNativeSvgIconById,
  getNativeSvgIconForCategory
} from '../src/utils/nativeSvgIcons';

describe('Native SVG Icons Suite', () => {
  it('should contain a curated collection of standard SVG icons', () => {
    expect(NATIVE_SVG_ICONS.length).toBeGreaterThanOrEqual(20);
  });

  it('should validate all SVG icons have required valid properties and paths', () => {
    for (const icon of NATIVE_SVG_ICONS) {
      expect(icon.id).toBeDefined();
      expect(icon.id.length).toBeGreaterThan(1);
      expect(icon.name).toBeDefined();
      expect(icon.category).toBeDefined();
      expect(icon.svg).toBeDefined();
      expect(icon.svg.length).toBeGreaterThan(5);
      // Valid SVG tags
      expect(icon.svg).toMatch(/<(path|rect|circle|line|polyline|polygon)/);
    }
  });

  it('should retrieve icons by ID correctly', () => {
    const film = getNativeSvgIconById('film');
    expect(film).toBeDefined();
    expect(film?.name).toContain('Cinéma');

    const sparkles = getNativeSvgIconById('sparkles');
    expect(sparkles).toBeDefined();
    expect(sparkles?.name).toContain('Intelligence Artificielle');

    const unknown = getNativeSvgIconById('non-existent-xyz');
    expect(unknown).toBeUndefined();
  });

  it('should return appropriate fallback icon for any category', () => {
    const entertainment = getNativeSvgIconForCategory('Entertainment');
    expect(entertainment.id).toBe('film');

    const productivity = getNativeSvgIconForCategory('Productivity');
    expect(productivity.id).toBe('sparkles');

    const utilities = getNativeSvgIconForCategory('Utilities');
    expect(utilities.id).toBe('zap');

    const transport = getNativeSvgIconForCategory('Transport');
    expect(transport.id).toBe('train');

    const general = getNativeSvgIconForCategory('UnknownCustomCategory');
    expect(general.id).toBe('feather');
  });
});
