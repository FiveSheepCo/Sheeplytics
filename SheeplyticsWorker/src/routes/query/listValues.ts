import type { IRequest } from "itty-router"

import Database from "../../database"
import { arraify, FilterBuilder } from "../../utils"

type QueryParams = {
	"filter[appId]"?: string
	"filter[userId]"?: string
	"filter[eventName]"?: string,
	"order"?: "asc" | "desc",
}

type GeneralResult = {
	app_id: string,
	user_id: string,
	name: string,
	value: string,
	possible_values: Array<string>,
}

type DatabaseResult = Array<GeneralResult>
type RouteResult = Array<GeneralResult>

/** Route for querying analytics data */
export default async function handler(request: IRequest, env: Env): Promise<RouteResult> {

	// Parse query parameters
	const params = request.query as QueryParams
	const appIdFilter = arraify(params['filter[appId]'])
	const userIdFilter = arraify(params['filter[userId]'])
	const eventNameFilter = arraify(params['filter[eventName]'])
	const order = params.order?.toUpperCase() ?? 'DESC'

	// Create database connection
	const db = new Database(env.ANALYTICS_DB)

	// Build where clause
	const { whereClause, queryBindings } = new FilterBuilder()
		.equalsAny('json_value.app_id', appIdFilter)
		.equalsAny('json_value.user_id', userIdFilter)
		.equalsAny('json_value.event_name', eventNameFilter)
		.build()

	// Build select clause
	const selectClause = (() => {
		return `
			json_value.app_id AS app_id,
			json_value.user_id AS user_id,
			json_value.event_name AS name,
			json_value.json_value AS value
		`.trim()
	})()

	// Build query
	const query = `
		SELECT ${selectClause}
		FROM JsonValues json_value
		${whereClause ? `WHERE ${whereClause}` : ''}
		ORDER BY json_value.value_id ${order}
	`

	// Execute query
	const result = await db.db.prepare(query).bind(...queryBindings).all()
	const rows = Object.values(result.results) as DatabaseResult

	// Return results
	return rows as Array<GeneralResult>
}
