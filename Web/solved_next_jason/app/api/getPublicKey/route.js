import { NextResponse } from 'next/server';
import { readFileSync } from 'fs';
import path from 'path';

const PUBKEY = readFileSync(path.join(process.cwd(), 'public.pem'), 'utf8');

export async function GET(req) {
	try {
		return NextResponse.json({ PUBKEY });
	} catch (error) {
		console.error('Error retrieving public key:', error);
		return NextResponse.json({ error: 'Failed to retrieve public key' }, { status: 500 });
	}
}
