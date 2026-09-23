// Theme colours are CSS variables (they switch with light / dark / pink).
// Tailwind cannot apply an opacity modifier (bg-japandi-pine/10) to a plain
// var(), so those classes were silently dropped; color-mix keeps them working.
const withAlpha = (v) => `color-mix(in srgb, var(${v}) calc(<alpha-value> * 100%), transparent)`;

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ['class'],
  content: [
    './src/**/*.{js,ts,jsx,tsx,mdx}',
    '../../packages/ui/src/**/*.{js,ts,jsx,tsx,mdx}'
  ],
  theme: {
    extend: {
      colors: {
        japandi: {
          bg: withAlpha('--color-bg-canvas'),
          canvas: withAlpha('--color-bg-canvas'),
          surface: withAlpha('--color-bg-surface'),
          elevated: withAlpha('--color-bg-elevated'),
          border: withAlpha('--color-border-subtle'),
          'border-strong': withAlpha('--color-border-strong'),
          'border-faint': withAlpha('--color-border-faint'),
          text: withAlpha('--color-text-primary'),
          muted: withAlpha('--color-text-secondary'),
          subtle: withAlpha('--color-text-tertiary'),
          pine: withAlpha('--color-accent-pine'),
          'pine-light': withAlpha('--color-accent-pine-light'),
          terracotta: withAlpha('--color-accent-terracotta'),
          'terracotta-light': withAlpha('--color-accent-terracotta-light'),
          clay: withAlpha('--color-accent-clay'),
          sand: withAlpha('--color-accent-sand'),
          slate: withAlpha('--color-accent-slate'),
          akane: withAlpha('--color-accent-akane')
        }
      },
      fontFamily: {
        sans: ['SF Pro Display', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'sans-serif'],
        mono: ['SF Mono', 'monospace']
      },
      borderRadius: {
        'japandi-xs': '6px',
        'japandi-sm': '8px',
        'japandi-md': '14px',
        'japandi-lg': '20px',
        'japandi-xl': '24px',
        'japandi-2xl': '28px',
        'japandi-3xl': '36px',
        'japandi-full': '9999px'
      },
      boxShadow: {
        'japandi-xs': '0 1px 3px rgba(0, 0, 0, 0.04)',
        'japandi-sm': '0 2px 8px -2px rgba(28, 28, 25, 0.04), 0 1px 4px -1px rgba(28, 28, 25, 0.02)',
        'japandi-md': '0 8px 24px -4px rgba(28, 28, 25, 0.06), 0 2px 8px -2px rgba(28, 28, 25, 0.03)',
        'japandi-lg': '0 16px 40px -8px rgba(28, 28, 25, 0.08), 0 4px 16px -4px rgba(28, 28, 25, 0.04)'
      }
    }
  },
  plugins: []
};
