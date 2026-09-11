import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useSubscriptionStore } from '../src/store/useSubscriptionStore';
import {
  fetchGoogleUserProfile,
  pushToGoogleDrive,
  pullFromGoogleDrive,
  disconnectGoogleAccount
} from '../src/services/googleDriveSync';
import * as core from '@subflow/core';

describe('GoogleDriveSync Application Service', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
    useSubscriptionStore.getState().setGoogleAccount(null);
    useSubscriptionStore.getState().setDriveSyncStatus('idle');
  });

  describe('fetchGoogleUserProfile', () => {
    it('fetches and normalizes google user information', async () => {
      globalThis.fetch = vi.fn().mockResolvedValue({
        ok: true,
        json: async () => ({
          email: 'test@subflow.io',
          name: 'Richard Subflow',
          picture: 'https://example.com/avatar.png'
        })
      });

      const profile = await fetchGoogleUserProfile('mock_token_123');
      expect(profile.email).toBe('test@subflow.io');
      expect(profile.name).toBe('Richard Subflow');
      expect(profile.picture).toBe('https://example.com/avatar.png');
    });

    it('throws error when google userinfo returns non-200', async () => {
      globalThis.fetch = vi.fn().mockResolvedValue({
        ok: false,
        status: 401
      });

      await expect(fetchGoogleUserProfile('invalid_token')).rejects.toThrow(
        /Failed to retrieve Google user profile/i
      );
    });
  });

  describe('disconnectGoogleAccount', () => {
    it('clears google account and sets status to idle', () => {
      useSubscriptionStore.getState().setGoogleAccount({
        email: 'user@example.com',
        name: 'User',
        accessToken: 'token-xyz'
      });
      useSubscriptionStore.getState().setDriveSyncStatus('synced');

      disconnectGoogleAccount();

      const state = useSubscriptionStore.getState();
      expect(state.googleAccount).toBeNull();
      expect(state.driveSyncStatus).toBe('idle');
    });
  });

  describe('pushToGoogleDrive', () => {
    it('does nothing if no user is connected', async () => {
      const searchSpy = vi.spyOn(core, 'searchAppDataBackup');
      await pushToGoogleDrive();
      expect(searchSpy).not.toHaveBeenCalled();
    });

    it('uploads backup snapshot to Google Drive when account is present', async () => {
      useSubscriptionStore.getState().setGoogleAccount({
        email: 'user@example.com',
        name: 'User',
        accessToken: 'valid_token'
      });

      const searchSpy = vi.spyOn(core, 'searchAppDataBackup').mockResolvedValue(null as any);
      const uploadSpy = vi.spyOn(core, 'uploadAppDataBackup').mockResolvedValue({ id: 'new_file' } as any);

      await pushToGoogleDrive();

      expect(searchSpy).toHaveBeenCalledWith('valid_token');
      expect(uploadSpy).toHaveBeenCalledWith('valid_token', expect.any(Object), undefined);
      expect(useSubscriptionStore.getState().driveSyncStatus).toBe('synced');
    });

    it('catches upload errors and updates sync error status', async () => {
      useSubscriptionStore.getState().setGoogleAccount({
        email: 'user@example.com',
        name: 'User',
        accessToken: 'valid_token'
      });

      vi.spyOn(core, 'searchAppDataBackup').mockRejectedValue(new Error('Drive Quota Exceeded'));

      await expect(pushToGoogleDrive()).rejects.toThrow('Drive Quota Exceeded');

      expect(useSubscriptionStore.getState().driveSyncStatus).toBe('error');
      expect(useSubscriptionStore.getState().driveSyncError).toBe('Drive Quota Exceeded');
    });
  });

  describe('pullFromGoogleDrive', () => {
    it('throws when pulling without active connection', async () => {
      await expect(pullFromGoogleDrive()).rejects.toThrow(/Non connecté à Google Drive/i);
    });

    it('restores state when backup exists on Drive', async () => {
      useSubscriptionStore.getState().setGoogleAccount({
        email: 'user@example.com',
        name: 'User',
        accessToken: 'valid_token'
      });

      vi.spyOn(core, 'searchAppDataBackup').mockResolvedValue({ id: 'drive_file_123' } as any);
      vi.spyOn(core, 'downloadAppDataBackup').mockResolvedValue({
        subscriptions: [{ id: 'sub-restored', name: 'Restored Sub', amount: 12, category: 'Tech', cycle: 'Monthly', startDate: '2026-01-01' }],
        profile: { spendingGoal: 300 }
      } as any);

      await pullFromGoogleDrive();

      const state = useSubscriptionStore.getState();
      expect(state.subscriptions.some((s) => s.id === 'sub-restored')).toBe(true);
      expect(state.profile.spendingGoal).toBe(300);
      expect(state.driveSyncStatus).toBe('synced');
    });

    it('throws and sets error status when no backup is found on Drive', async () => {
      useSubscriptionStore.getState().setGoogleAccount({
        email: 'user@example.com',
        name: 'User',
        accessToken: 'valid_token'
      });

      vi.spyOn(core, 'searchAppDataBackup').mockResolvedValue(null as any);

      await expect(pullFromGoogleDrive()).rejects.toThrow(/Aucune sauvegarde trouvée/i);
      expect(useSubscriptionStore.getState().driveSyncStatus).toBe('error');
    });
  });
});
