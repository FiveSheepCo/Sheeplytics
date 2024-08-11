import type { IRequest } from "itty-router"

import Database from "../../database"
import type { EventKind, JsonString } from "../../types"
import { arraify, FilterBuilder } from "../../utils"

type QueryParams = {
	"filter[appId]"?: string
	"filter[userId]"?: string
	"filter[eventKind]"?: EventKind,
	"filter[eventName]"?: string,
	"filter[startDate]"?: string,
	"filter[endDate]"?: string,
	"order"?: "asc" | "desc",
}

type RouteResult = Array<{
	app_id: string,
	user_id: string,
	event_name: string,
	event_kind: EventKind,
	event_data: JsonString,
	event_metadata: JsonString
}>

/** Route for querying analytics data */
export default async function handler(request: IRequest, env: Env): Promise<RouteResult> {

	// Parse query parameters
	const params = request.query as QueryParams
	const appIdFilter = arraify(params['filter[appId]'])
	const userIdFilter = arraify(params['filter[userId]'])
	const eventKindFilter = arraify(params['filter[eventKind]'])
	const eventNameFilter = arraify(params['filter[eventName]'])
	const startDateFilter = params['filter[startDate]']
	const endDateFilter = params['filter[endDate]']
	const order = params.order?.toUpperCase() ?? 'DESC'

	// Create database connection
	const db = new Database(env.ANALYTICS_DB)

	// Build where clause
	const { whereClause, queryBindings } = new FilterBuilder()
		.equalsAny('app.app_id', appIdFilter)
		.equalsAny('user.user_id', userIdFilter)
		.equalsAny('event.kind', eventKindFilter)
		.equalsAny('event.name', eventNameFilter)
		.between('event.timestamp', startDateFilter, endDateFilter)
		.build()

	// Build query
	const query = `
		SELECT
			app.app_id AS app_id,
			user.user_id AS user_id,
			event.name AS event_name,
			event.kind AS event_kind,
			event.inner_data AS event_data,
			event.metadata AS event_metadata
		FROM Events event
		JOIN Users user ON event.user_id = user.user_id
		JOIN Apps app ON user.app_id = app.app_id
		${whereClause ? `WHERE ${whereClause}` : ''}
		ORDER BY event.timestamp ${order}
	`

	// Execute query
	const result = await db.db.prepare(query).bind(...queryBindings).all()
	const rows = Object.values(result.results) as RouteResult

	// Return results
	return rows
}
