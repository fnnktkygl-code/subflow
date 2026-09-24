'use client';

// One companion, in continuity. When a form opens, the companion leaves its home in
// the header: it crouches, jumps and lands on the form's top edge (or walks in from
// the side of the screen when the page has no home spot). On the edge it waves, naps,
// wakes up and watches the field being filled, scratches its head at an error. When
// the form closes it jumps back home (for joy after a success) and the header
// companion takes over. A custom integration built on the Uko pack's public API
// (states, walk, lookAt, step); none of this ships in the pack as is.

import React, { useEffect, useRef, useState } from 'react';
import { loadUkoEngine, UKO_THEME } from './UkoMascot';
import { ukoStage } from './ukoBus';
import { useSubscriptionStore } from '../../store/useSubscriptionStore';

type Api = {
  setState(s: string): void; startWalk(dir: number, speed: number): void; stopWalk(): void;
  getWalkVelocity(): number; lookAt(t: Element | null): void; step(ms: number): void;
};
type Mode = 'home' | 'going' | 'perched' | 'returning';
type Box = { x: number; y: number; w: number; h: number };

const FEET = 1408 / 1536;            // feet line inside the mascot box
const TAKEOFF = 828, LANDING = 1512; // the engine's celebration jump: flight window (ms)
const SPOT = 0.7;                    // where it settles on the edge (fraction of its width)
const clamp = (v: number, a = 0, b = 1) => Math.max(a, Math.min(b, v));

export const UkoTraveler: React.FC = () => {
  const boxEl = useRef<HTMLDivElement | null>(null);
  const mascotEl = useRef<HTMLElement | null>(null);
  const [ready, setReady] = useState(false);
  const [shown, setShown] = useState(false);
  const [size, setSize] = useState({ w: 88, h: 132 });
  const companion = useSubscriptionStore((s) => s.profile.companion) || 'uko';
  const themeMode = useSubscriptionStore((s) => s.profile.themeMode) || 'light';
  const colors = UKO_THEME[themeMode] ?? UKO_THEME.light!;
  const st = useRef({ mode: 'home' as Mode, anchor: null as Element | null, box: { x: 0, y: 0, w: 88, h: 132 } as Box, raf: 0, timers: [] as number[], nap: 'awake' as 'awake' | 'asleep', verdict: null as null | 'error' | 'success' });
  const api = () => (mascotEl.current as unknown as { mascot?: Api } | null)?.mascot;

  useEffect(() => { let alive = true; loadUkoEngine().then(() => alive && setReady(true)).catch(() => {}); return () => { alive = false; }; }, []);

  useEffect(() => {
    if (!ready) return;
    const s = st.current;
    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const place = (b: Box) => { s.box = b; const el = boxEl.current; if (el) el.style.transform = `translate(${b.x.toFixed(1)}px, ${b.y.toFixed(1)}px)`; };
    const clearTimers = () => { s.timers.forEach(clearTimeout); s.timers = []; cancelAnimationFrame(s.raf); };
    const later = (ms: number, f: () => void) => s.timers.push(window.setTimeout(f, ms));
    const homeBox = (): Box | null => { const h = ukoStage.home(); if (!h) return null; const r = h.getBoundingClientRect(); return { x: r.left, y: r.top, w: r.width, h: r.height }; };
    const perchBox = (w: number, h: number): Box | null => {
      const a = s.anchor; if (!a || !a.isConnected) return null;
      const r = a.getBoundingClientRect();
      return { x: r.left + r.width * SPOT - w / 2, y: r.top - h * FEET + 3, w, h };
    };
    // A jump along a parabola, timed on the engine's own celebration jump.
    const jump = (from: Box, to: () => Box, skipCrouch: boolean, onLand: () => void) => {
      const m = api(); if (!m) return;
      m.lookAt(null); m.setState('success');
      if (skipCrouch) m.step(TAKEOFF);            // already airborne: no crouch on a vanishing edge
      const t0 = performance.now() - (skipCrouch ? TAKEOFF : 0);
      const tick = (now: number) => {
        const el = now - t0, u = clamp((el - TAKEOFF) / (LANDING - TAKEOFF)), dest = to();
        // Arc height: a real hop, but the head (and raised hands) never leaves the screen.
        const room = Math.min(from.y, dest.y) + dest.h * 0.02;
        const arc = clamp(Math.abs(dest.y - from.y) * 0.5 + 30, 12, Math.max(12, room));
        place({ x: from.x + (dest.x - from.x) * u, y: from.y + (dest.y - from.y) * u - 4 * arc * u * (1 - u), w: dest.w, h: dest.h });
        if (el < LANDING + 60) s.raf = requestAnimationFrame(tick); else onLand();
      };
      s.raf = requestAnimationFrame(tick);
    };
    // On the edge: settle, wave, then nap until a field is used.
    const settle = () => {
      const m = api(); if (!m) return;
      s.mode = 'perched'; s.nap = 'awake';
      later(250, () => { if (s.mode === 'perched' && !s.verdict) m.setState('welcome'); });
      later(3000, () => { if (s.mode === 'perched' && !s.verdict && s.nap === 'awake') { s.nap = 'asleep'; m.setState('sleep'); } });
      // Follow the edge (the modal grows when an error message appears).
      const follow = () => { if (s.mode !== 'perched') return; const b = perchBox(s.box.w, s.box.h); if (b) place(b); s.raf = requestAnimationFrame(follow); };
      s.raf = requestAnimationFrame(follow);
    };
    const go = (anchor: Element) => {
      clearTimers();
      const m = api(); if (!m || reduced) return;
      s.anchor = anchor; s.verdict = null; s.mode = 'going';
      const home = homeBox();
      if (home) {
        setSize({ w: home.w, h: home.h }); place(home); setShown(true); ukoStage.away(true);
        jump(home, () => perchBox(home.w, home.h) ?? home, false, () => { m.setState('idle'); settle(); });
      } else {
        // No home on this page: walk in from the right edge along the form's top.
        const w = 88, h = 132; setSize({ w, h });
        const target = perchBox(w, h); if (!target) return;
        let x = window.innerWidth - w * 0.4, last = performance.now();
        place({ ...target, x }); setShown(true);
        m.setState('idle'); m.startWalk(-1, 1.8);
        const tick = (now: number) => {
          const dt = Math.min(50, now - last) / 1000; last = now;
          const b = perchBox(w, h); if (!b) return;
          x += m.getWalkVelocity() * (h / 1536) * dt;
          if (x <= b.x) { place(b); m.stopWalk(); settle(); return; }
          place({ ...b, x }); s.raf = requestAnimationFrame(tick);
        };
        s.raf = requestAnimationFrame(tick);
      }
    };
    const back = () => {
      if (s.mode === 'home') return;
      clearTimers();
      const m = api(); const from = { ...s.box };
      s.mode = 'returning'; s.anchor = null;
      if (!m) { setShown(false); ukoStage.away(false); s.mode = 'home'; return; }
      const home = homeBox();
      const dest = home ?? { x: window.innerWidth + 20, y: from.y + 80, w: from.w, h: from.h };
      // Straight into the air (the form is going away), land home, finish the move there,
      // then hand over to the header companion.
      jump(from, () => homeBox() ?? dest, true, () => {
        later(s.verdict === 'success' ? 1900 : 500, () => { m.setState('idle'); later(350, () => { setShown(false); ukoStage.away(false); s.mode = 'home'; }); });
      });
    };
    const off = ukoStage.on((e) => {
      if (e.type === 'perch') { if (e.anchor) go(e.anchor); else back(); }
      if (e.type === 'verdict') {
        s.verdict = e.result;
        const m = api(); if (!m || s.mode !== 'perched') return;
        if (e.result === 'error') {
          m.setState('error');
          const sel = (s.anchor as HTMLElement | null)?.dataset.ukoError;
          m.lookAt(sel ? document.querySelector(sel) : null);
          later(3800, () => { s.verdict = null; });
        }
      }
    });
    // Filling a field wakes it up; it watches that field.
    const onFocus = (ev: FocusEvent) => {
      const m = api(), t = ev.target;
      if (!m || s.mode !== 'perched' || !(t instanceof HTMLElement) || !s.anchor?.parentElement?.contains(t)) return;
      if (!t.matches('input, select, textarea, button, [role="combobox"]')) return;
      if (s.nap === 'asleep') { s.nap = 'awake'; m.setState('wake'); }
      m.lookAt(t);
    };
    document.addEventListener('focusin', onFocus);
    return () => { off(); clearTimers(); document.removeEventListener('focusin', onFocus); };
  }, [ready]);

  return (
    <div
      ref={boxEl}
      aria-hidden="true"
      className="fixed left-0 top-0 z-[60] pointer-events-none"
      style={{ width: size.w, height: size.h, visibility: shown ? 'visible' : 'hidden' }}
    >
      {ready && (
        <uko-mascot
          ref={mascotEl as React.Ref<HTMLElement>}
          state="idle"
          character={companion}
          hair="original"
          brand={colors.brand}
          hair-color={colors.hair}
          interactive="false"
          style={{ width: '100%', height: '100%', display: 'block' }}
        />
      )}
    </div>
  );
};
