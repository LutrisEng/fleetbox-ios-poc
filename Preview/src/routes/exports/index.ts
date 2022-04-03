import { v4 as uuidv4 } from 'uuid';

/** @type {import('@sveltejs/kit').RequestHandler} */
export async function post({ request }) {
	const body = await request.arrayBuffer();
	const id = uuidv4();
	await EXPORTS.put(id, body);
	return {
		headers: { Location: `/exports/${id}` },
		status: 302
	};
}
