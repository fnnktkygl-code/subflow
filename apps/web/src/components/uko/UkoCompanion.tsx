'use client';

// Uko, the SubFlow companion.
// - Its mood mirrors the dashboard insight (nothing tracked yet, payment coming,
//   budget exceeded, all good). A mood is *expressed* when it appears, then Uko
//   relaxes into its (animated) idle: a signal shown non-stop turns into noise.
//   It is expressed again when it changes, when Uko is tapped, or when the user
//   comes back to the tab.
// - Any screen can make it react through ukoBus (success after an add, error on
//   an invalid form, thinking in the simulator…).
// - It falls asleep after a while without any activity and wakes up as soon as
//   the user moves, like someone keeping you company.

import React, { useCallback, useEffect, useRef, useState } from 'react';
import { UkoMascot } from './UkoMascot';
import { ukoBus, UkoState } from './ukoBus';

const ONE_SHOTS = new Set<UkoState>(['welcome', 'success', 'error', 'empty', 'wake']);
const EXPRESS_MS = 7000;         // how long a persistent mood (thinking, loading) is shown
const SLEEP_AFTER_MS = 45000;    // no pointer, key, scroll or touch for this long → nap
const REEXPRESS_AFTER_HIDDEN_MS = 30000;

export const UkoCompanion: React.FC<{ mood: UkoState; className?: string; label?: string }> = ({ mood, className, label }) => {
  const [override, setOverride] = useState<UkoState | null>(null);
  const [settled, setSettled] = useState(false);   // the mood has been expressed
  const [asleep, setAsleepState] = useState(false);
  const asleepRef = useRef(false);
  const setAsleep = useCallback((v: boolean) => { asleepRef.current = v; setAsleepState(v); }, []);
  const [waking, setWaking] = useState(false);
  const timer = useRef<number | undefined>(undefined);
  const expressTimer = useRef<number | undefined>(undefined);

  const express = useCallback(() => { setSettled(false); }, []);

  // A new mood is expressed again (e.g. the budget becomes exceeded).
  useEffect(() => { express(); }, [mood, express]);

  // Persistent moods relax after a few seconds; one-shots settle on `complete`.
  useEffect(() => {
    window.clearTimeout(expressTimer.current);
    if (!settled && !ONE_SHOTS.has(mood) && mood !== 'idle') {
      expressTimer.current = window.setTimeout(() => setSettled(true), EXPRESS_MS);
    }
    return () => window.clearTimeout(expressTimer.current);
  }, [mood, settled]);

  useEffect(() => ukoBus.on(({ state, holdMs }) => {
    window.clearTimeout(timer.current);
    setAsleep(false);
    // Reset first so the same reaction twice in a row plays twice.
    setOverride(null);
    requestAnimationFrame(() => setOverride(state));
    // One-shots end on the engine's `complete` event; holds end on a timer.
    if (!ONE_SHOTS.has(state) || holdMs) {
      timer.current = window.setTimeout(() => setOverride(null), holdMs ?? 2600);
    }
  }), [setAsleep]);
  useEffect(() => () => window.clearTimeout(timer.current), []);

  // Nap after inactivity, wake up on the first sign of life.
  useEffect(() => {
    let idleTimer: number | undefined;
    let hiddenAt = 0;
    const arm = () => {
      window.clearTimeout(idleTimer);
      idleTimer = window.setTimeout(() => setAsleep(true), SLEEP_AFTER_MS);
    };
    const onActivity = () => {
      if (asleepRef.current) { setWaking(true); setAsleep(false); }
      arm();
    };
    const onVisibility = () => {
      if (document.hidden) { hiddenAt = Date.now(); return; }
      if (hiddenAt && Date.now() - hiddenAt > REEXPRESS_AFTER_HIDDEN_MS) express();
      onActivity();
    };
    const events: (keyof WindowEventMap)[] = ['pointermove', 'pointerdown', 'keydown', 'scroll', 'touchstart'];
    events.forEach((e) => window.addEventListener(e, onActivity, { passive: true }));
    document.addEventListener('visibilitychange', onVisibility);
    arm();
    return () => {
      window.clearTimeout(idleTimer);
      events.forEach((e) => window.removeEventListener(e, onActivity));
      document.removeEventListener('visibilitychange', onVisibility);
    };
  }, [express, setAsleep]);

  const handleComplete = useCallback((done: UkoState) => {
    if (done === 'wake') setWaking(false);
    else if (override && done === override) setOverride(null);
    else if (done === mood) setSettled(true);
  }, [override, mood]);

  const moodState: UkoState = settled || mood === 'sleep' ? 'idle' : mood;
  const state: UkoState = override ?? (asleep ? 'sleep' : waking ? 'wake' : moodState);
  return (
    <div onClick={express} className={className}>
      <UkoMascot state={state} className="w-full h-full" label={label} onComplete={handleComplete} />
    </div>
  );
};
