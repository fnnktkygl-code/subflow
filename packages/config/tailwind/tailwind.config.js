/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ['class'],
  theme: {
    extend: {
      colors: {
        japandi: {
          bg: 'var(--color-bg-canvas)',
          surface: 'var(--color-bg-surface)',
          elevated: 'var(--color-bg-elevated)',
          border: 'var(--color-border-subtle)',
          'border-strong': 'var(--color-border-strong)',
          text: 'var(--color-text-primary)',
          muted: 'var(--color-text-secondary)',
          subtle: 'var(--color-text-tertiary)',
          pine: 'var(--color-accent-pine)',
          terracotta: 'var(--color-accent-terracotta)',
          clay: 'var(--color-accent-clay)',
          sand: 'var(--color-accent-sand)'
        }
      },
      fontFamily: {
        sans: ['var(--font-geist-sans)', 'SF Pro Display', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
        mono: ['var(--font-geist-mono)', 'SF Mono', 'monospace']
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
