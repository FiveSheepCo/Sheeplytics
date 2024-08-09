import Database from "../database"
import { ActionEvent, BaseEvent, FlagEvent, TypedEvent } from "../types"

type IngestResponseKind = 'acknowledged' | 'rejected'

type IngestResponse = {
	kind: IngestResponseKind
}

/** Ingestion route for analytics events. */
export default async function handler(request: Request, env: Env, context: any): Promise<IngestResponse> {
	const json = await request.json()

	// Destructure base event
	const baseEvent = json as BaseEvent

	// Decode specific event data
	const innerEvent = JSON.parse(atob(baseEvent.data))
	console.log('Received event:', {
		...baseEvent,
		data: innerEvent,
	})

	// Create database connection
	const database = new Database(env.ANALYTICS_DB)

	async function insertAs<T>(): Promise<any> {
		try {
			await database.insertEventAs<T>(innerEvent)
			return { kind: 'acknowledged' }
		} catch {
			return { kind: 'rejected' }
		}
	}

	// Parse typed event
	switch (baseEvent.kind) {
		case 'flag': return await insertAs<FlagEvent>()
		case 'action': return await insertAs<ActionEvent>()
		default: {
			console.log('Unknown event kind:', baseEvent.kind)
			return { kind: 'rejected' }
		}
	}
}
