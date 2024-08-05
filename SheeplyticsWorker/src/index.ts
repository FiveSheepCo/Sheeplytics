import { AutoRouter } from 'itty-router'

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

type EventKind = 'flag' | 'action'

interface BaseEvent {
	kind: EventKind
	data: string
}

interface TypedEvent<T> extends Omit<BaseEvent, 'data'> {
	data: T
}

type FlagEvent = TypedEvent<{ name: string, value: boolean }>
type ActionEvent = TypedEvent<{ name: string, value: string }>

type IngestResponseKind = 'acknowledged' | 'rejected'

type IngestResponse = {
	kind: IngestResponseKind
}

/** Ingestion route for analytics events. */
async function ingest(request: Request, context: any): Promise<IngestResponse> {
	const json = await request.json()

	// Destructure base event
	const {
		kind,
		data: eventData,
	} = json as BaseEvent

	// Decode specific event data
	const innerEvent = JSON.parse(atob(eventData))

	// Parse typed event
	switch (kind) {
		case 'flag': {
			const event = innerEvent as TypedEvent<FlagEvent>
			console.log({
				event: 'receivedEvent',
				eventType: 'flagEvent',
				eventData: event,
			})
			return { kind: 'acknowledged'}
		}
		case 'action': {
			const event = innerEvent as TypedEvent<ActionEvent>
			console.log({
				event: 'receivedEvent',
				eventType: 'actionEvent',
				eventData: event,
			})
			return { kind: 'acknowledged' }
		}
		default: {
			console.log({
				event: 'receivedEvent',
				eventType: 'unknown',
				eventData: innerEvent,
			})
			return { kind: 'rejected' }
		}
	}
}

router
	.post('/ingest', ingest)

export default router
