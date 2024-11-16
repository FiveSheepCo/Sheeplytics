import type { IRequest } from "itty-router"

import Database from "../database"
import SimilarityCache from "../similarity_cache"
import type { BaseEvent, TypedEvent, EventKind } from "../types"

type IngestResponseKind = 'acknowledged' | 'rejected'
type InsertionResultKind = 'success' | 'cached' | 'failure'

type IngestResponse = {
	message: IngestResponseKind
	status: number
}

async function handleEventPayload(payload: unknown, database: Database, cache: SimilarityCache, env: Env): Promise<InsertionResultKind> {

	// Decode specific event data
	const baseEvent = payload as BaseEvent
	const innerEvent: Record<string, unknown> = JSON.parse(atob(baseEvent.data))
	const typedEvent: TypedEvent<EventKind, unknown> = { ...baseEvent, data: innerEvent }

	// Check if event is the same as another recent event
	if (await cache.exists(typedEvent)) {
		return 'cached'
	}

	// Insert event into database
	try {
		await database.insertEvent(typedEvent)
		await cache.put(typedEvent)
		return 'success'
	} catch {
		return 'failure'
	}
}

/** Ingestion route for analytics events. */
export default async function handler(request: IRequest, env: Env): Promise<IngestResponse> {
	const json = await request.json()

	// Initialize database and cache
	const database = new Database(env.ANALYTICS_DB)
	const cache = new SimilarityCache(env.SIMILARITY_CACHE)

	// Handle batched events
	const isBatch = Array.isArray(json)
	const events = isBatch ? json : [json]
	const results: InsertionResultKind[] = []

	// Insert each event into the database
	for (const event of events) {
		results.push(await handleEventPayload(event, database, cache, env))
	}

	// A batch is considered rejected if all events are rejected
	const allRejected = results.every(result => result === 'failure')

	// Return response
	return {
		message: allRejected ? 'rejected' : 'acknowledged',
		status: allRejected ? 500 : 200
	}
}
