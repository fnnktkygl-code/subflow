// bff/server.js
// SubFlow Secure Backend-for-Frontend (BFF)

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 4000;

const CLIENT_ID = process.env.TRUELAYER_CLIENT_ID || 'trhack-0b37ee';
const CLIENT_SECRET = process.env.TRUELAYER_CLIENT_SECRET || '';
const IS_PRODUCTION = process.env.NODE_ENV === 'production';

const AUTH_BASE_URL = IS_PRODUCTION
  ? 'https://auth.truelayer.com'
  : 'https://auth.truelayer-sandbox.com';

const API_BASE_URL = IS_PRODUCTION
  ? 'https://api.truelayer.com'
  : 'https://api.truelayer-sandbox.com';

// Security Middlewares
app.use(helmet());
app.use(cors({ origin: true }));
app.use(express.json());

// Rate Limiter: 100 requests per 15 minutes per IP
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: { error: 'Too many requests, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api/', limiter);

// 1. Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', environment: IS_PRODUCTION ? 'production' : 'sandbox', timestamp: new Date().toISOString() });
});

// 2. Providers list
app.get('/api/auth/providers', async (req, res) => {
  const countryCode = (req.query.country || 'FR').toUpperCase();
  try {
    const response = await axios.get(`${AUTH_BASE_URL}/api/providers`, { timeout: 10000 });
    const allProviders = response.data || [];
    const filtered = allProviders
      .filter((p) => {
        const c = (p.country_code || p.country || '').toUpperCase();
        return c === countryCode;
      })
      .sort((a, b) => (a.name || '').localeCompare(b.name || ''));
    res.json(filtered);
  } catch (error) {
    console.error('Error fetching providers:', error.message);
    res.status(500).json({ error: 'Failed to fetch bank providers' });
  }
});

// 3. Secure Token Exchange (holds CLIENT_SECRET on server side)
app.post('/api/auth/token', async (req, res) => {
  const { code, redirect_uri, code_verifier } = req.body;
  if (!code) {
    return res.status(400).json({ error: 'Missing authorization code' });
  }

  try {
    const params = new URLSearchParams();
    params.append('grant_type', 'authorization_code');
    params.append('client_id', CLIENT_ID);
    if (CLIENT_SECRET) {
      params.append('client_secret', CLIENT_SECRET);
    }
    params.append('redirect_uri', redirect_uri || 'http://localhost:3000/callback');
    params.append('code', code);
    if (code_verifier) {
      params.append('code_verifier', code_verifier);
    }

    const response = await axios.post(`${AUTH_BASE_URL}/connect/token`, params.toString(), {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      timeout: 15000,
    });

    res.json({
      access_token: response.data.access_token,
      expires_in: response.data.expires_in,
      token_type: response.data.token_type,
    });
  } catch (error) {
    const status = error.response ? error.response.status : 500;
    const msg = error.response?.data?.error_description || error.message;
    console.error('Token exchange failure:', status, msg);
    res.status(status).json({ error: 'Token exchange failed', details: msg });
  }
});

// 4. Accounts Proxy
app.get('/api/data/accounts', async (req, res) => {
  const authHeader = req.headers['authorization'];
  if (!authHeader) {
    return res.status(401).json({ error: 'Missing Authorization header' });
  }

  try {
    const response = await axios.get(`${API_BASE_URL}/data/v1/accounts`, {
      headers: { Authorization: authHeader },
      timeout: 15000,
    });
    res.json(response.data);
  } catch (error) {
    const status = error.response ? error.response.status : 500;
    res.status(status).json({ error: 'Failed to fetch accounts' });
  }
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`[SubFlow BFF] Server running on http://localhost:${PORT} (${IS_PRODUCTION ? 'PROD' : 'SANDBOX'})`);
  });
}

module.exports = app;
