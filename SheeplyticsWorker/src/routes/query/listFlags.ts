import type { IRequest } from "itty-router"

import Database from "../../database"
import { arraify, FilterBuilder } from "../../utils"

type AggregationKind = 'count'

type QueryParams = {
	"filter[appId]"?: string
	"filter[userId]"?: string
	"filter[eventName]"?: string,
	"aggregate"?: AggregationKind,
	"order"?: "asc" | "desc",
}

type GeneralResult = {
	app_id: string,
	user_id: string,
	name: string,
	is_active: boolean,
}

type CountAggregateResult = { count: number }
type AggregateResult = CountAggregateResult

type DatabaseResult = Array<GeneralResult | AggregateResult>
type RouteResult = Array<GeneralResult> | AggregateResult

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
		.equalsAny('flag.app_id', appIdFilter)
		.equalsAny('flag.user_id', userIdFilter)
		.equalsAny('flag.event_name', eventNameFilter)
		.build()

	// Build select clause
	const selectClause = (() => {
		switch (params.aggregate) {
			case 'count': return 'COUNT(*) AS count'
			default: return `
				flag.app_id AS app_id,
				flag.user_id AS user_id,
				flag.event_name AS name,
				flag.is_active AS is_active
			`.trim()
		}
	})()

	// Build query
	const query = `
		SELECT ${selectClause}
		FROM Flags flag
		${whereClause ? `WHERE ${whereClause}` : ''}
		ORDER BY flag.flag_id ${order}
	`

	// Execute query
	const result = await db.db.prepare(query).bind(...queryBindings).all()
	const rows = Object.values(result.results) as DatabaseResult

	// Return results
	return params.aggregate === undefined
		? rows as Array<GeneralResult>
		: rows[0] as CountAggregateResult
}
