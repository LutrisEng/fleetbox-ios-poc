import { encode as encodeBase64 } from 'base64-arraybuffer';

/** @type {import('./index').RequestHandler} */
export async function get({ params }) {
	const data = await EXPORTS.get(params.id, 'arrayBuffer');
	if (data == null) {
		return {
			status: 404
		};
	} else {
		return {
			status: 200,
			body: {
				envelope: encodeBase64(data)
			}
		};
	}
}
