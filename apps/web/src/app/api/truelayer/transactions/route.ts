import { NextRequest, NextResponse } from 'next/server';

export async function GET(req: NextRequest) {
  try {
    const authHeader = req.headers.get('authorization') || '';
    if (!authHeader.startsWith('Bearer ')) {
      return NextResponse.json({ error: 'Missing or invalid token' }, { status: 401 });
    }

    const { searchParams } = new URL(req.url);
    const accountId = searchParams.get('accountId');
    const from = searchParams.get('from');
    const to = searchParams.get('to');

    if (!accountId) {
      return NextResponse.json({ error: 'Missing accountId' }, { status: 400 });
    }

    let url = `https://api.truelayer.com/data/v1/accounts/${encodeURIComponent(accountId)}/transactions`;
    const q = new URLSearchParams();
    if (from) q.append('from', from);
    if (to) q.append('to', to);
    if (q.toString()) url += `?${q.toString()}`;

    const res = await fetch(url, {
      signal: AbortSignal.timeout(15000),
      cache: 'no-store',
      headers: { Authorization: authHeader }
    });

    const data = await res.json();
    return NextResponse.json(res.ok ? data : { error: 'Bank request failed' }, { status: res.status, headers: { 'Cache-Control': 'no-store' } });
  } catch (error: any) {
    return NextResponse.json(
      { error: 'Failed to fetch transactions' },
      { status: 500 }
    );
  }
}
