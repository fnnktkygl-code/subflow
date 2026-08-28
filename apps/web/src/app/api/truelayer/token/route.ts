import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  try {
    let body: any = {};
    try {
      body = await req.json();
    } catch (_) {
      body = {};
    }

    const { code, redirect_uri } = body;

    if (!code) {
      return NextResponse.json({ error: 'Missing code' }, { status: 400 });
    }

    const params = new URLSearchParams();
    params.append('grant_type', 'authorization_code');
    params.append('client_id', process.env.NEXT_PUBLIC_TRUELAYER_CLIENT_ID || 'subflow-6571e7');
    if (process.env.TRUELAYER_CLIENT_SECRET) {
      params.append('client_secret', process.env.TRUELAYER_CLIENT_SECRET);
    }
    params.append('redirect_uri', redirect_uri || 'https://subflowapp.vercel.app/callback');
    params.append('code', code);

    const res = await fetch('https://auth.truelayer.com/connect/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString()
    });

    const data = await res.json();
    return NextResponse.json(data, { status: res.status });
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message || 'Token exchange failed' },
      { status: 500 }
    );
  }
}
