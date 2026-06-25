import axios from 'axios';
import { env } from '$env/dynamic/public';

const api = axios.create({
	baseURL: env.PUBLIC_API_BASE_URL
});

export default api;

export type LambdaMessageResponse = {
	messageId: string;
	containsPlacki: boolean;
};

export async function sendMessageViaLambda(
	username: string,
	message: string
): Promise<LambdaMessageResponse> {
	const base = env.PUBLIC_LAMBDA_API_URL;
	if (!base) {
		throw new Error('PUBLIC_LAMBDA_API_URL is not configured');
	}

	const response = await fetch(`${base}/messages`, {
		method: 'POST',
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify({ username, message })
	});

	if (!response.ok) {
		throw new Error(`Lambda API error: ${response.status}`);
	}

	return response.json();
}
