import type { IRequest } from "itty-router"

import Database from "../database"
import type { BaseEvent, TypedEvent, EventKind } from "../types"

type IngestResponseKind = 'acknowledged' | 'rejected'

type IngestResponse = {
	message: IngestResponseKind
	status: number
}

/** Ingestion route for analytics events. */
export default async function handler(request: IRequest, env: Env): Promise<IngestResponse> {
	const json = await request.json()

	// Decode specific event data
	const baseEvent = json as BaseEvent
	const innerEvent: Record<string, unknown> = JSON.parse(atob(baseEvent.data))
	const typedEvent: TypedEvent<EventKind, unknown> = { ...baseEvent, data: innerEvent }

	// Create database connection
	const database = new Database(env.ANALYTICS_DB)

	try {
		await database.insertEvent(typedEvent)
		return { message: 'acknowledged', status: 200 }
	} catch(err) {
		console.log(err)
		return { message: 'rejected', status: 500 }
	}
}
