import type { IRequest } from "itty-router"

import Database from "../database"
import SimilarityCache from "../similarity_cache"
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

	// Check if event is the same as another recent event
	const cache = new SimilarityCache(env.SIMILARITY_CACHE)
	if (await cache.exists(typedEvent)) {
		return { message: 'rejected', status: 409 }
	}

	// Insert event into database
	try {
		const database = new Database(env.ANALYTICS_DB)
		await database.insertEvent(typedEvent)
		await cache.put(typedEvent)
		return { message: 'acknowledged', status: 200 }
	} catch(err) {
		console.log(err)
		return { message: 'rejected', status: 500 }
	}
}
