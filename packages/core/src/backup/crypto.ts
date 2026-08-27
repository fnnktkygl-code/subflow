/**
 * SubFlow Encrypted Backup Engine (AES-256-GCM + PBKDF2)
 * Pure client-side zero-knowledge encryption using native WebCrypto API.
 */

export interface EncryptedPayload {
  version: 1;
  salt: string; // Hex-encoded 16 bytes
  iv: string;   // Hex-encoded 12 bytes
  ciphertext: string; // Base64-encoded encrypted data
}

export async function encryptBackupData(data: unknown, password: string): Promise<string> {
  const jsonStr = JSON.stringify(data);
  const encoder = new TextEncoder();
  const dataBytes = encoder.encode(jsonStr);

  const salt = crypto.getRandomValues(new Uint8Array(16));
  const iv = crypto.getRandomValues(new Uint8Array(12));

  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    encoder.encode(password),
    { name: 'PBKDF2' },
    false,
    ['deriveKey']
  );

  const aesKey = await crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt,
      iterations: 100000,
      hash: 'SHA-256'
    },
    keyMaterial,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt']
  );

  const encryptedBuffer = await crypto.subtle.encrypt(
    { name: 'AES-GCM', iv },
    aesKey,
    dataBytes
  );

  const payload: EncryptedPayload = {
    version: 1,
    salt: uint8ToHex(salt),
    iv: uint8ToHex(iv),
    ciphertext: bufferToBase64(encryptedBuffer)
  };

  return JSON.stringify(payload, null, 2);
}

export async function decryptBackupData(encryptedJson: string, password: string): Promise<unknown> {
  const payload: EncryptedPayload = JSON.parse(encryptedJson);
  if (payload.version !== 1 || !payload.salt || !payload.iv || !payload.ciphertext) {
    throw new Error('Invalid backup file format.');
  }

  const salt = hexToUint8(payload.salt);
  const iv = hexToUint8(payload.iv);
  const ciphertextBytes = base64ToBuffer(payload.ciphertext);

  const encoder = new TextEncoder();
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    encoder.encode(password),
    { name: 'PBKDF2' },
    false,
    ['deriveKey']
  );

  const aesKey = await crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt: salt as BufferSource,
      iterations: 100000,
      hash: 'SHA-256'
    },
    keyMaterial,
    { name: 'AES-GCM', length: 256 },
    false,
    ['decrypt']
  );

  try {
    const decryptedBuffer = await crypto.subtle.decrypt(
      { name: 'AES-GCM', iv: iv as BufferSource },
      aesKey,
      ciphertextBytes as BufferSource
    );

    const decoder = new TextDecoder();
    const jsonStr = decoder.decode(decryptedBuffer);
    return JSON.parse(jsonStr);
  } catch (_) {
    throw new Error('Incorrect password or corrupted backup file.');
  }
}

// Helpers
function uint8ToHex(bytes: Uint8Array): string {
  return Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

function hexToUint8(hex: string): Uint8Array {
  const pairs = hex.match(/.{1,2}/g) || [];
  return new Uint8Array(pairs.map((byte) => parseInt(byte, 16)));
}

function bufferToBase64(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]!);
  }
  return btoa(binary);
}

function base64ToBuffer(base64: string): ArrayBuffer {
  const binaryString = atob(base64);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer as ArrayBuffer;
}
