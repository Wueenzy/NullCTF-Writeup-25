'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function Home() {
	const router = useRouter();
	const [username, setUsername] = useState('');
	const [inviteCode, setInviteCode] = useState('');
	const [status, setStatus] = useState('');

	const handleLogin = async e => {
		e.preventDefault();
		setStatus('');

		try {
			const response = await fetch(`/api/login?inviteCode=${inviteCode}`, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
				},
				body: JSON.stringify({ username }),
			});

			if (!response.ok) {
				console.log(response);
				throw new Error(response.status);
			}

			setStatus("Login successful! Here's a cookie: 🍪");

			if (username === 'admin')
				setTimeout(() => {
					router.push('/api/getPublicKey');
				}, 500);
		} catch (err) {
			console.log(err.message);
			if (err.message === '403') {
				setStatus('You can not log in as an admin.');
				return;
			} else if (err.message === '401') {
				setStatus('Invalid invite code.');
				return;
			} else setStatus('Login failed. Check your username or invite code.');
			console.log(err);
		}
	};

	return (
		<div style={{ textAlign: 'center', marginTop: '50px' }}>
			<h1 style={{ marginBottom: '20px' }}>Login</h1>
			{status && (
				<p
					style={{
						color: status === "Login successful! Here's a cookie: 🍪" ? 'green' : 'red',
						margin: '20px',
					}}
				>
					{status}
				</p>
			)}
			<form onSubmit={handleLogin} style={{ maxWidth: '300px', margin: '0 auto' }}>
				<div style={{ marginBottom: '15px' }}>
					<input
						type="text"
						value={username}
						onChange={e => setUsername(e.target.value)}
						placeholder="Username"
						required
						style={{ width: '100%', padding: '8px' }}
					/>
				</div>
				<div style={{ marginBottom: '15px' }}>
					<input
						type="text"
						value={inviteCode}
						onChange={e => setInviteCode(e.target.value)}
						placeholder="Invite Code"
						style={{ width: '100%', padding: '8px' }}
					/>
				</div>
				<button
					type="submit"
					style={{
						width: '100%',
						padding: '10px',
						backgroundColor: '#0070f3',
						color: 'white',
						border: 'none',
						borderRadius: '4px',
						cursor: 'pointer',
					}}
				>
					Login
				</button>
			</form>
		</div>
	);
}
