// Tiny event bus: any screen can ask Uko to react (add → success, invalid form → error…).
// UkoCompanion listens and plays the reaction over its resting state.

export type UkoState =
  | 'idle' | 'welcome' | 'thinking' | 'loading' | 'success' | 'error' | 'empty' | 'sleep' | 'wake';

export type UkoReaction = { state: UkoState; holdMs?: number };

type Listener = (r: UkoReaction) => void;
const listeners = new Set<Listener>();
// Gaze: any screen can make Uko look at an element for a moment (null = look away).
export type UkoLook = { target: Element | null; holdMs?: number };
type LookListener = (l: UkoLook) => void;
const lookListeners = new Set<LookListener>();

export const ukoBus = {
  emit(state: UkoState, holdMs?: number) {
    listeners.forEach((l) => l({ state, holdMs }));
  },
  on(listener: Listener) {
    listeners.add(listener);
    return () => { listeners.delete(listener); };
  },
  look(target: Element | null, holdMs?: number) {
    lookListeners.forEach((l) => l({ target, holdMs }));
  },
  onLook(listener: LookListener) {
    lookListeners.add(listener);
    return () => { lookListeners.delete(listener); };
  }
};
