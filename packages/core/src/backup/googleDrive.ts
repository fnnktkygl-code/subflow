/**
 * SubFlow Google Drive AppData Sync Engine
 * Uses the private, sandboxed `drive.appdata` scope (appDataFolder)
 * to store and retrieve client-side zero-knowledge encrypted/JSON snapshots.
 */

export interface GoogleDriveBackupFile {
  id: string;
  name: string;
  modifiedTime: string;
  size?: string;
}

export interface GoogleDriveSyncState {
  isConnected: boolean;
  userEmail?: string;
  lastSyncedAt?: string;
  autoSyncEnabled: boolean;
  status: 'idle' | 'syncing' | 'restoring' | 'success' | 'error';
  errorMessage?: string;
}

export const GOOGLE_DRIVE_BACKUP_FILENAME = 'subflow_backup.json';
export const GOOGLE_DRIVE_APPDATA_SCOPE = 'https://www.googleapis.com/auth/drive.appdata';

/**
 * Searches for existing SubFlow backup in the private appDataFolder.
 */
export async function searchAppDataBackup(
  accessToken: string,
  fetchFn: typeof fetch = fetch
): Promise<GoogleDriveBackupFile | null> {
  const url = `https://www.googleapis.com/drive/v3/files?spaces=appDataFolder&fields=files(id,name,modifiedTime,size)&q=name='${GOOGLE_DRIVE_BACKUP_FILENAME}' and trashed=false`;

  const response = await fetchFn(url, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      Accept: 'application/json'
    }
  });

  if (!response.ok) {
    throw new Error(`Google Drive API error: ${response.status} ${response.statusText}`);
  }

  const data = await response.json();
  const files: GoogleDriveBackupFile[] = data.files || [];
  return files.length > 0 && files[0] ? files[0] : null;
}

/**
 * Uploads (creates or replaces) SubFlow backup in the private appDataFolder.
 */
export async function uploadAppDataBackup(
  accessToken: string,
  payload: unknown,
  existingFileId?: string,
  fetchFn: typeof fetch = fetch
): Promise<GoogleDriveBackupFile> {
  const jsonContent = JSON.stringify(payload, null, 2);

  if (existingFileId) {
    // Update existing file content
    const updateUrl = `https://www.googleapis.com/upload/drive/v3/files/${existingFileId}?uploadType=media`;
    const res = await fetchFn(updateUrl, {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: jsonContent
    });

    if (!res.ok) {
      throw new Error(`Failed to update backup file: ${res.statusText}`);
    }

    return await res.json();
  }

  // Create new file with multipart upload in appDataFolder
  const metadata = {
    name: GOOGLE_DRIVE_BACKUP_FILENAME,
    parents: ['appDataFolder'],
    mimeType: 'application/json'
  };

  const boundary = '-------314159265358979323846';
  const delimiter = `\r\n--${boundary}\r\n`;
  const closeDelimiter = `\r\n--${boundary}--`;

  const multipartRequestBody =
    delimiter +
    'Content-Type: application/json; charset=UTF-8\r\n\r\n' +
    JSON.stringify(metadata) +
    delimiter +
    'Content-Type: application/json\r\n\r\n' +
    jsonContent +
    closeDelimiter;

  const createUrl = 'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&fields=id,name,modifiedTime,size';
  const res = await fetchFn(createUrl, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': `multipart/related; boundary=${boundary}`
    },
    body: multipartRequestBody
  });

  if (!res.ok) {
    throw new Error(`Failed to create backup in Google Drive: ${res.statusText}`);
  }

  return await res.json();
}

/**
 * Downloads and parses the backup file from Google Drive appDataFolder.
 */
export async function downloadAppDataBackup<T = unknown>(
  accessToken: string,
  fileId: string,
  fetchFn: typeof fetch = fetch
): Promise<T> {
  const url = `https://www.googleapis.com/drive/v3/files/${fileId}?alt=media`;

  const response = await fetchFn(url, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${accessToken}`
    }
  });

  if (!response.ok) {
    throw new Error(`Failed to download backup: ${response.statusText}`);
  }

  return await response.json();
}

/**
 * Deletes backup file from Google Drive appDataFolder.
 */
export async function deleteAppDataBackup(
  accessToken: string,
  fileId: string,
  fetchFn: typeof fetch = fetch
): Promise<boolean> {
  const url = `https://www.googleapis.com/drive/v3/files/${fileId}`;

  const response = await fetchFn(url, {
    method: 'DELETE',
    headers: {
      Authorization: `Bearer ${accessToken}`
    }
  });

  return response.ok;
}
