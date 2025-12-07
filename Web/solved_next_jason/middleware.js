import { NextResponse } from 'next/server';

export async function middleware(req) {
	const url = req.nextUrl;

	const inviteCode = url.searchParams.get('inviteCode');
	const validInviteCode = process.env.INVITE_CODE || 'secret_invite_code';

	if (inviteCode && inviteCode === validInviteCode) {
		return NextResponse.next();
	}

	if (url.pathname === '/api/login') return NextResponse.json({ error: 'Invalid invite code' }, { status: 401 });

	const token = req.cookies.get('token')?.value;
	let isValidToken = false;

	if (token) {
		try {
			const baseUrl = `${url.protocol}//${url.host}`;
			const verifyResponse = await fetch(`${baseUrl}/token/verify`, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
				},
				body: JSON.stringify({ token }),
			});

			if (verifyResponse.ok) {
				const result = await verifyResponse.json();
				if (result.valid) isValidToken = true;
			}
		} catch (error) {
			console.error('Token verification error:', error);
		}
	}

	if (isValidToken) {
		return NextResponse.next();
	}

	return NextResponse.json({ error: 'Access Denied: Valid invitation code or authentication required' }, { status: 401 });
}

export const config = {
	matcher: '/api/:path*',
};
