'use client';

import {
  searchAppDataBackup,
  uploadAppDataBackup,
  downloadAppDataBackup,
  GOOGLE_DRIVE_APPDATA_SCOPE,
  Subscription,
  UserProfile
} from '@subflow/core';
import { useSubscriptionStore, GoogleAccount } from '../store/useSubscriptionStore';

declare global {
  interface Window {
    google?: any;
    gapi?: any;
  }
}

// Built-in SubFlow Google OAuth Client ID
export const DEFAULT_GOOGLE_CLIENT_ID =
  process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID || '702043703591-tdvapt1cb96h1q3npg8bnp1p73rvgvib.apps.googleusercontent.com';



/**
 * Initializes and requests token authorization from Google Identity Services (GIS).
 */
export async function requestGoogleDriveAccess(clientId?: string): Promise<string> {
  const activeClientId = clientId || useSubscriptionStore.getState().googleClientId || DEFAULT_GOOGLE_CLIENT_ID;

  await loadGoogleIdentity();
  return new Promise((resolve, reject) => {
    if (typeof window === 'undefined') {
      return reject(new Error('Window is not defined'));
    }

    if (!window.google?.accounts?.oauth2) {
      return reject(new Error('Google Identity Services script not yet loaded. Please retry in a moment.'));
    }

    if (!activeClientId) {
      return reject(new Error('Google Client ID is missing. Please configure a Client ID in Settings or provide one.'));
    }

    try {
      const client = window.google.accounts.oauth2.initTokenClient({
        client_id: activeClientId,
        scope: `${GOOGLE_DRIVE_APPDATA_SCOPE} https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile`,
        prompt: 'consent',
        callback: async (tokenResponse: any) => {
          if (tokenResponse.error) {
            reject(new Error(tokenResponse.error_description || tokenResponse.error));
            return;
          }
          if (!tokenResponse.access_token) {
            reject(new Error('No access token received from Google.'));
            return;
          }
          resolve(tokenResponse.access_token);
        },
        error_callback: (error: any) => {
          reject(new Error(error.message || 'Google OAuth prompt was cancelled or blocked.'));
        }
      });

      client.requestAccessToken();
    } catch (err: any) {
      reject(err);
    }
  });
}

/**
 * Fetches user profile (email, name, picture) using the Google access token.
 */
export async function fetchGoogleUserProfile(accessToken: string): Promise<{ email: string; name: string; picture?: string }> {
  const res = await fetch('https://www.googleapis.com/oauth2/v3/userinfo', {
    headers: { Authorization: `Bearer ${accessToken}` }
  });

  if (!res.ok) {
    throw new Error('Failed to retrieve Google user profile.');
  }

  const data = await res.json();
  return {
    email: data.email || 'Google User',
    name: data.name || data.given_name || 'Utilisateur Google',
    picture: data.picture
  };
}

/**
 * High-level login handler: connects Google, stores user, and automatically syncs/restores data from Google Drive.
 */
export async function loginWithGoogleAndSync(customClientId?: string): Promise<void> {
  const store = useSubscriptionStore.getState();
  store.setDriveSyncStatus('syncing');

  try {
    const accessToken = await requestGoogleDriveAccess(customClientId);
    const userInfo = await fetchGoogleUserProfile(accessToken);

    const account: GoogleAccount = {
      email: userInfo.email,
      name: userInfo.name,
      picture: userInfo.picture,
      accessToken,
      expiresAt: Date.now() + 3500 * 1000,
      lastSyncedAt: new Date().toISOString()
    };

    // Do not enable background writes until restoration has finished.

    // 1. Search for existing cloud backup
    const existingBackupFile = await searchAppDataBackup(accessToken);

    if (existingBackupFile) {
      // 2. Download and restore cloud data
      const cloudData = await downloadAppDataBackup<{
        subscriptions?: Subscription[];
        profile?: Partial<UserProfile>;
        version?: number;
      }>(accessToken, existingBackupFile.id);

      if (cloudData && Array.isArray(cloudData.subscriptions)) {
        store.restoreFromCloud({
          subscriptions: cloudData.subscriptions,
          profile: cloudData.profile
        });
      } else {
        // Cloud backup exists but empty: sync current local data to it
        await uploadAppDataBackup(
          accessToken,
          {
            version: 1,
            exportedAt: new Date().toISOString(),
            subscriptions: store.subscriptions,
            profile: store.profile
          },
          existingBackupFile.id
        );
      }
    } else {
      // 3. No backup on Drive yet: perform initial upload
      await uploadAppDataBackup(accessToken, {
        version: 1,
        exportedAt: new Date().toISOString(),
        subscriptions: store.subscriptions,
        profile: store.profile
      });
    }

    store.setGoogleAccount(account);
    store.setDriveSyncStatus('synced');
  } catch (err: any) {
    store.setDriveSyncStatus('error', err.message || 'Échec de la connexion à Google Drive');
    throw err;
  }
}

/**
 * Manually or automatically pushes current store snapshot to Google Drive appDataFolder.
 */
export async function pushToGoogleDrive(): Promise<void> {
  const store = useSubscriptionStore.getState();
  const account = store.googleAccount;

  if (!account || !account.accessToken) {
    return;
  }

  if (account.expiresAt && account.expiresAt <= Date.now()) {
    store.setDriveSyncStatus('error', 'Session Google expirée. Reconnectez-vous.');
    throw new Error('Session Google expirée. Reconnectez-vous.');
  }
  store.setDriveSyncStatus('syncing');

  try {
    const existingBackupFile = await searchAppDataBackup(account.accessToken);

    const payload = {
      version: 1,
      exportedAt: new Date().toISOString(),
      subscriptions: store.subscriptions,
      profile: store.profile
    };

    await uploadAppDataBackup(
      account.accessToken,
      payload,
      existingBackupFile ? existingBackupFile.id : undefined
    );

    store.setDriveSyncStatus('synced');
  } catch (err: any) {
    store.setDriveSyncStatus('error', err.message || 'Échec de la sauvegarde Google Drive');
    throw err;
  }
}

/**
 * Pulls and restores the latest snapshot from Google Drive.
 */
export async function pullFromGoogleDrive(): Promise<void> {
  const store = useSubscriptionStore.getState();
  const account = store.googleAccount;

  if (!account || !account.accessToken) {
    throw new Error('Non connecté à Google Drive');
  }

  if (account.expiresAt && account.expiresAt <= Date.now()) {
    store.setDriveSyncStatus('error', 'Session Google expirée. Reconnectez-vous.');
    throw new Error('Session Google expirée. Reconnectez-vous.');
  }
  store.setDriveSyncStatus('syncing');

  try {
    const existingBackupFile = await searchAppDataBackup(account.accessToken);

    if (!existingBackupFile) {
      throw new Error('Aucune sauvegarde trouvée sur Google Drive.');
    }

    const cloudData = await downloadAppDataBackup<{
      subscriptions?: Subscription[];
      profile?: Partial<UserProfile>;
    }>(account.accessToken, existingBackupFile.id);

    if (cloudData) {
      store.restoreFromCloud(cloudData);
    }
    store.setDriveSyncStatus('synced');
  } catch (err: any) {
    store.setDriveSyncStatus('error', err.message || 'Erreur lors de la récupération Google Drive');
    throw err;
  }
}

/**
 * Disconnects the Google account and sets sync state to idle.
 */
export function disconnectGoogleAccount(): void {
  const store = useSubscriptionStore.getState();
  store.setGoogleAccount(null);
  store.setDriveSyncStatus('idle');
}

let identityLoading: Promise<void> | undefined;
function loadGoogleIdentity(): Promise<void> {
  if (typeof window === 'undefined') return Promise.reject(new Error('Browser required'));
  if (window.google?.accounts?.oauth2) return Promise.resolve();
  if (!identityLoading) identityLoading = new Promise<void>((resolve, reject) => {
    const script = document.createElement('script');
    script.src = 'https://accounts.google.com/gsi/client';
    script.async = true;
    script.onload = () => resolve();
    script.onerror = () => { identityLoading = undefined; script.remove(); reject(new Error('Connexion Google indisponible. Réessayez.')); };
    document.head.appendChild(script);
  });
  return identityLoading;
}
