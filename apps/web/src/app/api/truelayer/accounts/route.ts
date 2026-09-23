import { NextRequest, NextResponse } from 'next/server';

export async function GET(req: NextRequest) {
  try {
    const authHeader = req.headers.get('authorization') || '';
    if (!authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ error: 'Missing or invalid token' }, { status: 401 });
    }

    const res = await fetch('https://api.truelayer.com/data/v1/accounts', {
      signal: AbortSignal.timeout(15000),
      cache: 'no-store',
      headers: { Authorization: authHeader }
    });

    const data = await res.json();
    return NextResponse.json(res.ok ? data : { error: 'Bank request failed' }, { status: res.status, headers: { 'Cache-Control': 'no-store' } });
  } catch (error: any) {
    return NextResponse.json(
      { error: 'Failed to fetch accounts' },
      { status: 500 }
    );
  }
}
