import { IRequest } from "itty-router"

import Database from "../database"
import { ActionEvent, BaseEvent, FlagEvent } from "../types"

type IngestResponseKind = 'acknowledged' | 'rejected'

type IngestResponse = {
	message: IngestResponseKind
	status: number
}

/** Ingestion route for analytics events. */
export default async function handler(request: IRequest, env: Env): Promise<IngestResponse> {
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

	async function insertAs<T>(): Promise<IngestResponse> {
		try {
			await database.insertEventAs<T>(innerEvent)
			return { message: 'acknowledged', status: 200 }
		} catch {
			return { message: 'rejected', status: 200 }
		}
	}

	// Parse typed event
	switch (baseEvent.kind) {
		case 'flag': return await insertAs<FlagEvent>()
		case 'action': return await insertAs<ActionEvent>()
		default: {
			console.log('Unknown event kind:', baseEvent.kind)
			return { message: 'rejected', status: 200 }
		}
	}
}
