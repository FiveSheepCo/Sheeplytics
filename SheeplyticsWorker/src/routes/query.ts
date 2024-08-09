import { IRequest } from "itty-router"

import Database from "../database"
import { EventKind } from "../types"

type QueryParams = {
	"filter[appId]"?: string
	"filter[userId]"?: string
	"filter[eventKind]"?: EventKind,
	"order"?: "asc" | "desc",
}

function valueOrArrayOfValuesToArray<T>(value: undefined | T | Array<T>): Array<T> {
	if (value === undefined) {
		return []
	} else if (Array.isArray(value)) {
		return value
	} else {
		return [value]
	}
}

/** Route for querying analytics data */
export default async function handler(request: IRequest, env: Env): Promise<any> {

	// Parse query parameters
	const params = request.query as QueryParams
	const appIdFilter = valueOrArrayOfValuesToArray(params['filter[appId]'])
	const userIdFilter = valueOrArrayOfValuesToArray(params['filter[userId]'])
	const eventKindFilter = valueOrArrayOfValuesToArray(params['filter[eventKind]'])
	const order = params.order?.toUpperCase() ?? 'DESC'

	// Create database connection
	const db = new Database(env.ANALYTICS_DB)

	// DEBUG: Create example data
	await db.createAppIfNotExists('app-test')
	await db.createUserIfNotExists('user-foo', 'app-test')
	await db.createUserIfNotExists('user-bar', 'app-test')
	await db.insertEvent({
		kind: 'flag',
		appId: 'app-test',
		userId: 'user-foo',
		timestamp: new Date(),
		data: { name: 'flag-1', value: true },
		metadata: { version: 1, debug: true }
	})

	const queryBindings: Array<string> = []
	function buildMultiValueFilter(values: Array<string>, column: string): Array<string> {
		if (values.length === 0) {
			return []
		}
		queryBindings.push(...values)
		return [`(${values.map(_ => `${column} = ?`).join(' OR ')})`]
	}

	// Build filter clauses
	const whereClauses = [
		...buildMultiValueFilter(appIdFilter, 'app.app_id'),
		...buildMultiValueFilter(userIdFilter, 'user.user_id'),
		...buildMultiValueFilter(eventKindFilter, 'event.kind'),
	].join(' AND ')

	// Build query
	const query = `
		SELECT
			app.app_id AS app_id,
			user.user_id AS user_id,
			event.kind AS event_kind,
			event.inner_data AS event_data,
			event.metadata AS event_metadata
		FROM Events event
		JOIN Users user ON event.user_id = user.user_id
		JOIN Apps app ON user.app_id = app.app_id
		${whereClauses ? `WHERE ${whereClauses}` : ''}
		ORDER BY event.timestamp ${order}
	`

	// Execute query
	const result = await db.db.prepare(query).bind(...queryBindings).all()
	const rows = result.results

	// Return results
	return Object.values(rows)
}
