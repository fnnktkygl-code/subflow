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

    let url = `https://api.truelayer.com/data/v1/accounts/${accountId}/transactions`;
    const q = new URLSearchParams();
    if (from) q.append('from', from);
    if (to) q.append('to', to);
    if (q.toString()) url += `?${q.toString()}`;

    const res = await fetch(url, {
      headers: { Authorization: authHeader }
    });

    const data = await res.json();
    return NextResponse.json(data, { status: res.status });
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message || 'Failed to fetch transactions' },
      { status: 500 }
    );
  }
}
