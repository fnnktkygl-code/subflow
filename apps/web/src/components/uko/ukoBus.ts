// Tiny event bus: any screen can ask Uko to react (add → success, invalid form → error…).
// UkoCompanion listens and plays the reaction over its resting state.

export type UkoState =
  | 'idle' | 'welcome' | 'thinking' | 'loading' | 'success' | 'error' | 'empty' | 'sleep' | 'wake';

export type UkoReaction = { state: UkoState; holdMs?: number };

type Listener = (r: UkoReaction) => void;
const listeners = new Set<Listener>();

export const ukoBus = {
  emit(state: UkoState, holdMs?: number) {
    listeners.forEach((l) => l({ state, holdMs }));
  },
  on(listener: Listener) {
    listeners.add(listener);
    return () => { listeners.delete(listener); };
  }
};
