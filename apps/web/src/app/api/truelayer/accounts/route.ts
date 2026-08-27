import { NextRequest, NextResponse } from 'next/server';

export async function GET(req: NextRequest) {
  try {
    const authHeader = req.headers.get('authorization') || '';
    const tokenFromHeader = authHeader.startsWith('Bearer ') ? authHeader.substring(7) : '';
    const searchParams = req.nextUrl.searchParams;
    const token = tokenFromHeader || searchParams.get('access_token');

    if (!token) {
      return NextResponse.json({ error: 'Missing access_token' }, { status: 401 });
    }

    const accountsRes = await fetch('https://api.truelayer.com/data/v1/accounts', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });

    const data = await accountsRes.json();

    if (!accountsRes.ok) {
      return NextResponse.json(
        { error: data.error_description || data.error || 'Failed to fetch accounts from TrueLayer' },
        { status: accountsRes.status }
      );
    }

    return NextResponse.json(data);
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message || 'Internal server error while fetching TrueLayer accounts' },
      { status: 500 }
    );
  }
}
