import type { IRequest } from "itty-router"

import Database from "../../database"
import { arraify, FilterBuilder } from "../../utils"

type AggregationKind = 'count' | 'sum' | 'avg'

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
type SumAggregateResult = { sum: number }
type AvgAggregateResult = { avg: number }
type AggregateResult = CountAggregateResult | SumAggregateResult | AvgAggregateResult

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
		.equalsAny('action.app_id', appIdFilter)
		.equalsAny('action.user_id', userIdFilter)
		.equalsAny('action.event_name', eventNameFilter)
		.build()

	// Build select clause
	const selectClause = (() => {
		switch (params.aggregate) {
			case 'count': return 'COUNT(*) AS count'
			case 'sum': return 'SUM(action.trigger_count) AS sum'
			case 'avg': return 'AVG(action.trigger_count) AS avg'
			default: return `
				action.app_id AS app_id,
				action.user_id AS user_id,
				action.event_name AS name,
				action.trigger_count AS trigger_count
			`.trim()
		}
	})()

	// Build query
	const query = `
		SELECT ${selectClause}
		FROM Actions action
		${whereClause ? `WHERE ${whereClause}` : ''}
		ORDER BY action.action_id ${order}
	`

	// Execute query
	const result = await db.db.prepare(query).bind(...queryBindings).all()
	const rows = Object.values(result.results) as DatabaseResult

	// Return results
	return params.aggregate === undefined
		? rows as Array<GeneralResult>
		: rows[0] as AggregateResult
}
