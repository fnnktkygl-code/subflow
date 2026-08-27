import { describe, it, expect, vi } from 'vitest';
import {
  searchAppDataBackup,
  uploadAppDataBackup,
  downloadAppDataBackup,
  deleteAppDataBackup,
  GOOGLE_DRIVE_BACKUP_FILENAME,
  GOOGLE_DRIVE_APPDATA_SCOPE
} from '../src/backup/googleDrive';

describe('Google Drive AppData Sync Engine', () => {
  const fakeToken = 'mock_oauth_access_token_12345';

  it('declares the exact private drive.appdata scope and standard filename', () => {
    expect(GOOGLE_DRIVE_APPDATA_SCOPE).toBe('https://www.googleapis.com/auth/drive.appdata');
    expect(GOOGLE_DRIVE_BACKUP_FILENAME).toBe('subflow_backup.json');
  });

  it('searches for existing backup in appDataFolder', async () => {
    const mockFetch = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({
        files: [
          {
            id: 'file_id_abc123',
            name: 'subflow_backup.json',
            modifiedTime: '2026-08-27T19:50:00Z',
            size: '2048'
          }
        ]
      })
    });

    const file = await searchAppDataBackup(fakeToken, mockFetch as any);
    expect(file).not.toBeNull();
    expect(file?.id).toBe('file_id_abc123');
    expect(mockFetch).toHaveBeenCalledWith(
      expect.stringContaining('spaces=appDataFolder'),
      expect.objectContaining({
        headers: expect.objectContaining({
          Authorization: `Bearer ${fakeToken}`
        })
      })
    );
  });

  it('returns null when no backup exists in appDataFolder', async () => {
    const mockFetch = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ files: [] })
    });

    const file = await searchAppDataBackup(fakeToken, mockFetch as any);
    expect(file).toBeNull();
  });

  it('uploads a new multipart backup to appDataFolder', async () => {
    const mockFetch = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({
        id: 'new_file_id_999',
        name: 'subflow_backup.json',
        modifiedTime: '2026-08-27T19:55:00Z'
      })
    });

    const payload = { subscriptions: [{ id: '1', name: 'Spotify', amount: 10.99 }] };
    const res = await uploadAppDataBackup(fakeToken, payload, undefined, mockFetch as any);

    expect(res.id).toBe('new_file_id_999');
    expect(mockFetch).toHaveBeenCalledWith(
      expect.stringContaining('uploadType=multipart'),
      expect.objectContaining({
        method: 'POST',
        body: expect.stringContaining('appDataFolder')
      })
    );
  });

  it('updates an existing backup file in place', async () => {
    const mockFetch = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => ({
        id: 'existing_file_id',
        name: 'subflow_backup.json',
        modifiedTime: '2026-08-27T19:56:00Z'
      })
    });

    const payload = { subscriptions: [{ id: '1', name: 'Netflix', amount: 13.49 }] };
    const res = await uploadAppDataBackup(fakeToken, payload, 'existing_file_id', mockFetch as any);

    expect(res.id).toBe('existing_file_id');
    expect(mockFetch).toHaveBeenCalledWith(
      'https://www.googleapis.com/upload/drive/v3/files/existing_file_id?uploadType=media',
      expect.objectContaining({
        method: 'PATCH'
      })
    );
  });

  it('downloads and parses backup file content', async () => {
    const backupContent = {
      version: '1.0.0',
      subscriptions: [{ id: 'sub_1', name: 'Canal+', amount: 22.99 }]
    };

    const mockFetch = vi.fn().mockResolvedValue({
      ok: true,
      json: async () => backupContent
    });

    const data = await downloadAppDataBackup(fakeToken, 'file_id_abc', mockFetch as any);
    expect(data).toEqual(backupContent);
  });

  it('deletes backup file on request', async () => {
    const mockFetch = vi.fn().mockResolvedValue({ ok: true });
    const success = await deleteAppDataBackup(fakeToken, 'file_to_delete', mockFetch as any);
    expect(success).toBe(true);
  });
});
