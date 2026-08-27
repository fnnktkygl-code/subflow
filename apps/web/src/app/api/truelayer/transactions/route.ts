import { NextRequest, NextResponse } from 'next/server';

export async function GET(req: NextRequest) {
  try {
    const authHeader = req.headers.get('authorization') || '';
    const tokenFromHeader = authHeader.startsWith('Bearer ') ? authHeader.substring(7) : '';
    const searchParams = req.nextUrl.searchParams;
    const token = tokenFromHeader || searchParams.get('access_token');
    const accountId = searchParams.get('account_id');

    if (!token) {
      return NextResponse.json({ error: 'Missing access_token' }, { status: 401 });
    }

    if (!accountId) {
      return NextResponse.json({ error: 'Missing account_id parameter' }, { status: 400 });
    }

    // Default to 90 days of transaction history as supported by French banks under STET
    const now = new Date();
    const ninetyDaysAgo = new Date();
    ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);

    const from = searchParams.get('from') || ninetyDaysAgo.toISOString();
    const to = searchParams.get('to') || now.toISOString();

    const txUrl = `https://api.truelayer.com/data/v1/accounts/${encodeURIComponent(accountId)}/transactions?from=${encodeURIComponent(from)}&to=${encodeURIComponent(to)}`;

    const txRes = await fetch(txUrl, {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });

    const data = await txRes.json();

    if (!txRes.ok) {
      return NextResponse.json(
        { error: data.error_description || data.error || 'Failed to fetch transactions from TrueLayer' },
        { status: txRes.status }
      );
    }

    return NextResponse.json(data);
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message || 'Internal server error while fetching TrueLayer transactions' },
      { status: 500 }
    );
  }
}
