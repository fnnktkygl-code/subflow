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

// Continuity: there is one companion. It lives in a "home" (its spot in the header)
// and can travel to a perch (a modal's top edge) and back; UkoTraveler plays the trip
// and the home companion hides meanwhile.
type StageEvent =
  | { type: 'perch'; anchor: Element | null }          // go sit on this edge (null = come back)
  | { type: 'verdict'; result: 'error' | 'success' }   // the form's answer, seen from the perch
  | { type: 'away'; away: boolean };                    // the home companion is (not) travelling
const stageListeners = new Set<(e: StageEvent) => void>();
let home: Element | null = null;
export const ukoStage = {
  setHome(el: Element | null) { home = el; },
  home() { return home && home.isConnected && (home as HTMLElement).offsetParent !== null ? home : null; },
  perch(anchor: Element | null) { stageListeners.forEach((l) => l({ type: 'perch', anchor })); },
  verdict(result: 'error' | 'success') { stageListeners.forEach((l) => l({ type: 'verdict', result })); },
  away(away: boolean) { stageListeners.forEach((l) => l({ type: 'away', away })); },
  on(listener: (e: StageEvent) => void) { stageListeners.add(listener); return () => { stageListeners.delete(listener); }; }
};
