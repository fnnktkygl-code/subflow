import type { StateStorage } from 'zustand/middleware';
let unreadable = false;
let storageError: string | null = null;
export const getStorageError = () => storageError;
const WRITE_ERROR = 'Sauvegarde locale impossible (stockage plein ou bloqué). Vos modifications restent dans cette page : exportez-les avant de la fermer.';
function report(message: string | null) {
  storageError = message;
  if (typeof window !== 'undefined' && typeof window.dispatchEvent === 'function') window.dispatchEvent(new Event('subflow-storage-health'));
}

export function setBrowserStorageItemStrict(key: string, value: string): void {
  if (typeof window === 'undefined' || window.location?.pathname.startsWith('/demo')) return;
  if (unreadable) {
    report(WRITE_ERROR);
    throw new Error(WRITE_ERROR);
  }
  try {
    window.localStorage.setItem(key, value);
    report(null);
  } catch {
    report(WRITE_ERROR);
    throw new Error(WRITE_ERROR);
  }
}

export const browserStorage: StateStorage = {
  getItem(key) {
    if (typeof window === 'undefined' || window.location?.pathname.startsWith('/demo')) return null;
    try {
      const raw = window.localStorage.getItem(key);
      if (!raw) return null;
      const parsed = JSON.parse(raw);
      // Remove credentials on opening an old install, without waiting for an edit.
      if (parsed.state?.googleAccount) {
        delete parsed.state.googleAccount;
        delete parsed.state.driveSyncError;
        parsed.state.driveSyncStatus = 'idle';
        const clean = JSON.stringify(parsed);
        try {
          window.localStorage.setItem(key, clean);
          return clean;
        } catch {
          // A credential-bearing legacy snapshot must never be loaded again.
          try { window.localStorage.removeItem(key); } catch { /* The browser may block all storage access. */ }
          unreadable = true;
          report('Un ancien stockage contenant une connexion Google n’a pas pu être assaini. SubFlow a refusé de le charger : effacez les données du site avant de continuer.');
          return null;
        }
      }
      return raw;
    } catch {
      unreadable = true;
      report('Le stockage local est inaccessible ou endommagé. Les nouvelles modifications restent temporaires : exportez une sauvegarde avant de fermer cette page.');
      return null;
    }
  },
  setItem(key, value) {
    try { setBrowserStorageItemStrict(key, value); }
    catch { /* Regular edits stay available in memory and the global notice explains the risk. */ }
  },
  removeItem(key) {
    if (typeof window === 'undefined' || window.location?.pathname.startsWith('/demo')) return;
    try { window.localStorage.removeItem(key); } catch { report('Impossible d’effacer le stockage local. Vérifiez les autorisations du navigateur.'); }
  }
};
