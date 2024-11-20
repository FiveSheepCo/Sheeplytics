import type { IRequest } from "itty-router"

import Database from "../database"
import type { BaseEvent, TypedEvent, EventKind } from "../types"

type IngestResponseKind = 'acknowledged' | 'rejected'
type InsertionResultKind = 'success' | 'cached' | 'failure'

type IngestResponse = {
	message: IngestResponseKind
	status: number
}

async function handleEventPayload(payload: unknown, database: Database): Promise<InsertionResultKind> {

	// Decode specific event data
	const baseEvent = payload as BaseEvent
	const innerEvent: Record<string, unknown> = JSON.parse(atob(baseEvent.data))
	const typedEvent: TypedEvent<EventKind, unknown> = { ...baseEvent, data: innerEvent }

	// Insert event into database
	try {
		await database.insertEvent(typedEvent)
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

	// Handle batched events
	const isBatch = Array.isArray(json)
	const events = isBatch ? json : [json]
	const results: InsertionResultKind[] = []

	// Insert each event into the database
	for (const event of events) {
		results.push(await handleEventPayload(event, database))
	}

	// A batch is considered rejected if all events are rejected
	const allRejected = results.every(result => result === 'failure')

	// Return response
	return {
		message: allRejected ? 'rejected' : 'acknowledged',
		status: allRejected ? 500 : 200
	}
}
