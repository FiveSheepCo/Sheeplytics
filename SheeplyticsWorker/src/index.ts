import { AutoRouter } from 'itty-router'
import type { BaseEvent, TypedEvent, FlagEvent, ActionEvent } from './event'

/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run `npm run dev` in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run `npm run deploy` to publish your worker
 *
 * Bind resources to your worker in `wrangler.toml`. After adding bindings, a type definition for the
 * `Env` object can be regenerated with `npm run cf-typegen`.
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

const router = AutoRouter()

type IngestResponseKind = 'acknowledged' | 'rejected'

type IngestResponse = {
	kind: IngestResponseKind
}

/** Ingestion route for analytics events. */
async function ingest(request: Request, context: any): Promise<IngestResponse> {
	const json = await request.json()

	// Destructure base event
	const baseEvent = json as BaseEvent

	// Decode specific event data
	const innerEvent = JSON.parse(atob(baseEvent.data))
	console.log('Received event:', {
		...baseEvent,
		data: innerEvent,
	})

	// Parse typed event
	switch (baseEvent.kind) {
		case 'flag': {
			const event = innerEvent as TypedEvent<FlagEvent>
			return { kind: 'acknowledged'}
		}
		case 'action': {
			const event = innerEvent as TypedEvent<ActionEvent>
			return { kind: 'acknowledged' }
		}
		default: {
			console.log('Unknown event kind:', baseEvent.kind)
			return { kind: 'rejected' }
		}
	}
}

router
	.post('/ingest', ingest)

export default router
