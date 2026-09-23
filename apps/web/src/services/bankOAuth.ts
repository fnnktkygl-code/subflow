const KEY = 'subflow-bank-oauth';
const TTL = 10 * 60 * 1000;
const base64url = (bytes: Uint8Array) => btoa(String.fromCharCode(...bytes)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

export async function beginBankOAuth(bankId: string): Promise<string> {
  if (window.location.pathname.startsWith('/demo')) throw new Error('Connexion bancaire indisponible dans la démonstration');
  const state = base64url(crypto.getRandomValues(new Uint8Array(32)));
  const verifier = base64url(crypto.getRandomValues(new Uint8Array(32)));
  const challenge = base64url(new Uint8Array(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(verifier))));
  const redirectUri = `${window.location.origin}/callback`;
  sessionStorage.setItem(KEY, JSON.stringify({ state, verifier, createdAt: Date.now(), redirectUri }));
  const params = new URLSearchParams({ response_type: 'code', client_id: process.env.NEXT_PUBLIC_TRUELAYER_CLIENT_ID || 'subflow-6571e7', redirect_uri: redirectUri, scope: 'accounts transactions', country_code: 'FR', providers: bankId, provider_id: bankId, state, code_challenge: challenge, code_challenge_method: 'S256' });
  return `https://auth.truelayer.com/?${params}`;
}

export function consumeBankOAuth(state: string | null): { verifier: string; redirectUri: string } {
  const raw = sessionStorage.getItem(KEY);
  sessionStorage.removeItem(KEY);
  let saved;
  try { saved = raw ? JSON.parse(raw) : null; } catch { saved = null; }
  if (!state || !saved || saved.state !== state || !Number.isFinite(saved.createdAt) || Date.now() - saved.createdAt > TTL || saved.createdAt > Date.now() || !/^[A-Za-z0-9_-]{43}$/.test(saved.verifier) || saved.redirectUri !== `${window.location.origin}/callback`) {
    throw new Error('Autorisation bancaire expirée ou invalide. Recommencez la connexion depuis SubFlow.');
  }
  return saved;
}
