'use client';

// React wrapper around the <uko-mascot> web component (Uko Mascot Pack).
// The engine (~70 KB gzip, no dependency) is loaded once, lazily, from /vendor.
// Colours follow the SubFlow theme: sage face, pine hair in light mode;
// Uko adapts its lines to html.dark / data-theme by itself (theme="auto").

import React, { useEffect, useRef, useState } from 'react';
import { useSubscriptionStore } from '../../store/useSubscriptionStore';
import type { UkoState } from './ukoBus';

declare module 'react' {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace JSX {
    interface IntrinsicElements {
      'uko-mascot': React.DetailedHTMLProps<React.HTMLAttributes<HTMLElement>, HTMLElement> & {
        state?: string; hair?: string; brand?: string; 'hair-color'?: string; theme?: string;
        interactive?: string; 'one-shot'?: string; cheeks?: string;
      };
    }
  }
}

let enginePromise: Promise<void> | null = null;
export function loadUkoEngine(): Promise<void> {
  if (typeof window === 'undefined') return Promise.resolve();
  if (customElements.get('uko-mascot')) return Promise.resolve();
  if (!enginePromise) {
    enginePromise = new Promise((resolve, reject) => {
      const s = document.createElement('script');
      s.src = '/vendor/uko-mascot-engine.js';
      s.async = true;
      s.onload = () => resolve();
      s.onerror = () => { enginePromise = null; reject(new Error('Uko engine failed to load')); };
      document.head.appendChild(s);
    });
  }
  return enginePromise;
}

// SubFlow brand, per theme (face = brand fill, hair = accent).
const LIGHT = { brand: '#C9D8C4', hair: '#3B4D3C' };
export const UKO_THEME: Record<string, { brand: string; hair: string }> = {
  light: LIGHT,
  dark: { brand: '#8FA88C', hair: '#B4C7B1' },
  barbie: { brand: '#FBCFE8', hair: '#DB2777' }
};

export interface UkoMascotProps {
  state?: UkoState;
  hair?: string;
  interactive?: boolean;
  oneShot?: 'return' | 'loop';
  className?: string;
  label?: string;
  /** Force a palette (public pages stay light whatever the app theme). */
  palette?: keyof typeof UKO_THEME;
  onComplete?: (state: UkoState) => void;
}

export const UkoMascot: React.FC<UkoMascotProps> = ({
  state = 'idle', hair = 'original', interactive = true, oneShot = 'return', className, label, palette, onComplete
}) => {
  const ref = useRef<HTMLElement | null>(null);
  const [ready, setReady] = useState(false);
  const themeMode = useSubscriptionStore((s) => s.profile.themeMode) || 'light';
  const colors = UKO_THEME[palette ?? themeMode] ?? LIGHT;

  useEffect(() => {
    let alive = true;
    loadUkoEngine().then(() => alive && setReady(true)).catch(() => {});
    return () => { alive = false; };
  }, []);

  useEffect(() => {
    const el = ref.current;
    if (!el || !onComplete) return;
    const handler = (e: Event) => onComplete((e as CustomEvent).detail.state);
    el.addEventListener('complete', handler);
    return () => el.removeEventListener('complete', handler);
  }, [onComplete, ready]);

  return (
    <div className={className} role="img" aria-label={label || `Uko : ${state}`}>
      {ready && (
        <uko-mascot
          ref={ref as React.Ref<HTMLElement>}
          state={state}
          hair={hair}
          brand={colors.brand}
          hair-color={colors.hair}
          theme={palette ? (palette === 'dark' ? 'dark' : 'light') : 'auto'}
          interactive={String(interactive)}
          one-shot={oneShot}
          style={{ width: '100%', height: '100%', display: 'block' }}
        />
      )}
    </div>
  );
};
