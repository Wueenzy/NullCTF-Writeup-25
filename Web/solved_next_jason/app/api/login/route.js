import { NextResponse } from 'next/server';

export async function POST(request) {
	try {
		const body = await request.json();
		const { username } = body;

		if (!username) {
			return NextResponse.json({ error: 'Username is required' }, { status: 400 });
		} else if (username === 'admin') {
			return NextResponse.json({ error: 'Try harder' }, { status: 403 });
		}

		const signResponse = await fetch(new URL('/token/sign', request.url), {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({ username }),
		});

		if (!signResponse.ok) {
			throw new Error(`Token signing failed: ${signResponse.status}`);
		}

		const { token } = await signResponse.json();

		const response = NextResponse.json({ success: true });
		response.cookies.set({
			name: 'token',
			value: token,
			httpOnly: true,
		});

		return response;
	} catch (error) {
		console.error('Login error:', error);
		return NextResponse.json({ error: 'Authentication failed' }, { status: 500 });
	}
}
