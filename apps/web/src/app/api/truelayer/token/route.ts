import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  try {
    let body: any = {};
    try {
      body = await req.json();
    } catch (_) {
      // Defensive fallback for raw string body
      const text = await req.text();
      body = text ? JSON.parse(text) : {};
    }

    const { code, redirect_uri } = body;

    if (!code) {
      return NextResponse.json({ error: 'Missing authorization code' }, { status: 400 });
    }

    const clientId = process.env.TRUELAYER_CLIENT_ID || 'subflow-6571e7';
    const clientSecret = process.env.TRUELAYER_CLIENT_SECRET || '';

    const params = new URLSearchParams();
    params.append('grant_type', 'authorization_code');
    params.append('client_id', clientId);
    if (clientSecret) {
      params.append('client_secret', clientSecret);
    }
    params.append('redirect_uri', redirect_uri || 'https://subflowapp.vercel.app/callback');
    params.append('code', code);

    const tokenRes = await fetch('https://auth.truelayer.com/connect/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: params.toString()
    });

    const tokenData = await tokenRes.json();

    if (!tokenRes.ok) {
      return NextResponse.json(
        { error: tokenData.error_description || tokenData.error || 'Failed to exchange token with TrueLayer' },
        { status: tokenRes.status }
      );
    }

    return NextResponse.json({
      access_token: tokenData.access_token,
      refresh_token: tokenData.refresh_token,
      expires_in: tokenData.expires_in,
      token_type: tokenData.token_type
    });
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message || 'Internal server error during token exchange' },
      { status: 500 }
    );
  }
}
