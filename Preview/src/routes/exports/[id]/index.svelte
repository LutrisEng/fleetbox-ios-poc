<script lang="ts">
	import { decode as decodeBase64 } from 'base64-arraybuffer';
	import { decodeExportEnvelope } from '$lib/export';

	export let envelope: string;
	$: envelopeBuffer = decodeBase64(envelope);
	$: parsedEnvelope = decodeExportEnvelope(envelopeBuffer);
</script>

<div>
	<pre><code>{JSON.stringify(parsedEnvelope)}</code></pre>
</div>
