import { describe, it, expect, vi, beforeEach } from 'vitest';
import { NextRequest } from 'next/server';
import { POST as tokenRoute } from '../src/app/api/truelayer/token/route';
import { GET as accountsRoute } from '../src/app/api/truelayer/accounts/route';
import { GET as transactionsRoute } from '../src/app/api/truelayer/transactions/route';

describe('TrueLayer Serverless Proxy API Routes', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  describe('POST /api/truelayer/token', () => {
    it('returns 400 Bad Request if code is missing', async () => {
      const req = new NextRequest('http://localhost:3000/api/truelayer/token', {
        method: 'POST',
        body: JSON.stringify({})
      });

      const res = await tokenRoute(req);
      expect(res.status).toBe(400);

      const json = await res.json();
      expect(json.error).toBe('Missing code');
    });

    it('exchanges code for tokens successfully', async () => {
      globalThis.fetch = vi.fn().mockResolvedValue({
        status: 200,
        ok: true,
        json: async () => ({
          access_token: 'fake_access_token',
          refresh_token: 'fake_refresh_token',
          expires_in: 3600
        })
      });

      const req = new NextRequest('http://localhost:3000/api/truelayer/token', {
        method: 'POST',
        body: JSON.stringify({ code: 'valid_auth_code_123' })
      });

      const res = await tokenRoute(req);
      expect(res.status).toBe(200);

      const json = await res.json();
      expect(json.access_token).toBe('fake_access_token');
    });

    it('handles upstream fetch rejection gracefully with status 500', async () => {
      globalThis.fetch = vi.fn().mockRejectedValue(new Error('Network error'));

      const req = new NextRequest('http://localhost:3000/api/truelayer/token', {
        method: 'POST',
        body: JSON.stringify({ code: 'valid_auth_code_123' })
      });

      const res = await tokenRoute(req);
      expect(res.status).toBe(500);

      const json = await res.json();
      expect(json.error).toBe('Network error');
    });
  });

  describe('GET /api/truelayer/accounts', () => {
    it('returns 401 Unauthorized if Authorization header is missing or not Bearer', async () => {
      const req = new NextRequest('http://localhost:3000/api/truelayer/accounts', {
        method: 'GET'
      });

      const res = await accountsRoute(req);
      expect(res.status).toBe(401);

      const json = await res.json();
      expect(json.error).toBe('Missing or invalid token');
    });

    it('proxies request to TrueLayer with Authorization header', async () => {
      globalThis.fetch = vi.fn().mockResolvedValue({
        status: 200,
        ok: true,
        json: async () => ({
          results: [{ account_id: 'acc_123', display_name: 'Compte Courant' }]
        })
      });

      const req = new NextRequest('http://localhost:3000/api/truelayer/accounts', {
        method: 'GET',
        headers: {
          authorization: 'Bearer token_abc'
        }
      });

      const res = await accountsRoute(req);
      expect(res.status).toBe(200);

      const json = await res.json();
      expect(json.results[0].account_id).toBe('acc_123');
    });
  });

  describe('GET /api/truelayer/transactions', () => {
    it('returns 401 Unauthorized if Authorization header is missing', async () => {
      const req = new NextRequest('http://localhost:3000/api/truelayer/transactions?accountId=acc_123', {
        method: 'GET'
      });

      const res = await transactionsRoute(req);
      expect(res.status).toBe(401);
    });

    it('returns 400 Bad Request if accountId is missing', async () => {
      const req = new NextRequest('http://localhost:3000/api/truelayer/transactions', {
        method: 'GET',
        headers: {
          authorization: 'Bearer token_abc'
        }
      });

      const res = await transactionsRoute(req);
      expect(res.status).toBe(400);

      const json = await res.json();
      expect(json.error).toBe('Missing accountId');
    });

    it('proxies transaction query with accountId and date filters', async () => {
      globalThis.fetch = vi.fn().mockResolvedValue({
        status: 200,
        ok: true,
        json: async () => ({
          results: [
            { transaction_id: 'tx_1', description: 'NETFLIX.COM', amount: 13.49 }
          ]
        })
      });

      const req = new NextRequest(
        'http://localhost:3000/api/truelayer/transactions?accountId=acc_123&from=2026-01-01&to=2026-08-01',
        {
          method: 'GET',
          headers: {
            authorization: 'Bearer token_abc'
          }
        }
      );

      const res = await transactionsRoute(req);
      expect(res.status).toBe(200);

      const json = await res.json();
      expect(json.results.length).toBe(1);
      expect(globalThis.fetch).toHaveBeenCalledWith(
        expect.stringContaining('accounts/acc_123/transactions?from=2026-01-01&to=2026-08-01'),
        expect.objectContaining({
          headers: { Authorization: 'Bearer token_abc' }
        })
      );
    });
  });
});
