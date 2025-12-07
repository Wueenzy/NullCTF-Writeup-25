import { NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';
import { readFileSync } from 'fs';
import path from 'path';
const PUBKEY = readFileSync(path.join(process.cwd(), 'public.pem'), 'utf8');

function verifyToken(token) {
	return jwt.verify(token, PUBKEY, { algorithms: ['RS256', 'HS256'] });
}

export async function POST(request) {
	try {
		const { token } = await request.json();

		if (!token) {
			return NextResponse.json({ error: 'Token required' }, { status: 400 });
		}

		const payload = verifyToken(token);
		return NextResponse.json({ valid: true, payload });
	} catch (error) {
		console.error('Token verification error:', error);
		return NextResponse.json({ valid: false, error: 'Invalid token' }, { status: 400 });
	}
}
