import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  try {
    let body: any = {};
    try {
      body = await req.json();
    } catch (_) {
      body = {};
    }

    const { code, redirect_uri, code_verifier } = body || {};

    if (typeof code !== 'string' || !code || code.length > 4096) {
      return NextResponse.json({ error: 'Missing code' }, { status: 400 });
    }

    if (typeof code_verifier !== 'string' || !/^[A-Za-z0-9._~-]{43,128}$/.test(code_verifier) || redirect_uri !== `${new URL(req.url).origin}/callback`) return NextResponse.json({ error: 'Invalid OAuth transaction' }, { status: 400 });

    const params = new URLSearchParams();
    params.append('grant_type', 'authorization_code');
    params.append('client_id', process.env.NEXT_PUBLIC_TRUELAYER_CLIENT_ID || 'subflow-6571e7');
    if (process.env.TRUELAYER_CLIENT_SECRET) {
      params.append('client_secret', process.env.TRUELAYER_CLIENT_SECRET);
    }
    params.append('redirect_uri', redirect_uri || 'https://subflowapp.vercel.app/callback');
    params.append('code', code);
    params.append('code_verifier', code_verifier);

    const res = await fetch('https://auth.truelayer.com/connect/token', {
      method: 'POST',
      signal: AbortSignal.timeout(15000),
      cache: 'no-store',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString()
    });

    const data = await res.json();
    return NextResponse.json(res.ok ? { access_token: data.access_token, expires_in: data.expires_in } : { error: 'Bank authorization failed' }, { status: res.status, headers: { 'Cache-Control': 'no-store' } });
  } catch (error: any) {
    return NextResponse.json(
      { error: 'Token exchange failed' },
      { status: 500 }
    );
  }
}
