import { NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';
import { readFileSync } from 'fs';
import path from 'path';
const PRIVKEY = readFileSync(path.join(process.cwd(), 'private.pem'), 'utf8');

function signToken(payload) {
	return jwt.sign(payload, PRIVKEY, { algorithm: 'RS256' });
}

export async function POST(request) {
	try {
		const body = await request.json();

		if (!body || Object.keys(body).length === 0) {
			return NextResponse.json({ error: 'Payload required' }, { status: 400 });
		} else if (body.username === 'admin') {
			return NextResponse.json({ error: 'Try harder' }, { status: 403 });
		}

		const token = signToken(body);
		return NextResponse.json({ token });
	} catch (error) {
		console.error('Token signing error:', error);
		return NextResponse.json({ token: 'error', error: 'Failed to sign token' }, { status: 500 });
	}
}
