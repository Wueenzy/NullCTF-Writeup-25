import { NextResponse } from 'next/server';

export async function GET(req) {
	try {
		const token = req.cookies.get('token')?.value;
		const valid = await fetch(new URL('/token/verify', req.url), {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({ token }),
		});
		const payload = await valid.json();
		if (!payload.valid) return NextResponse.json({ error: 'Invalid token or token missing' }, { status: 403 });
		if (payload.payload.username !== 'admin') return NextResponse.json({ error: 'You need to be admin!' }, { status: 403 });

		const flag = process.env.FLAG;

		return NextResponse.json({ flag });
	} catch (error) {
		console.error('Error retrieving public key:', error);
		return NextResponse.json({ error: 'Failed to retrieve public key' }, { status: 500 });
	}
}
