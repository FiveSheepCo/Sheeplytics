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
	value: string,
	possible_values: Array<string>,
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
		.equalsAny('choice.app_id', appIdFilter)
		.equalsAny('choice.user_id', userIdFilter)
		.equalsAny('choice.event_name', eventNameFilter)
		.build()

	// Build select clause
	const selectClause = (() => {
		switch (params.aggregate) {
			case 'count': return 'COUNT(*) AS count'
			default: return `
				choice.app_id AS app_id,
				choice.user_id AS user_id,
				choice.event_name AS name,
				choice.choice_value AS value
			`.trim()
		}
	})()

	// Build query
	const query = `
		SELECT ${selectClause}
		FROM Choices choice
		${whereClause ? `WHERE ${whereClause}` : ''}
		ORDER BY choice.choice_id ${order}
	`

	// Execute query
	const result = await db.db.prepare(query).bind(...queryBindings).all()
	const rows = Object.values(result.results) as DatabaseResult

	// if (params.aggregate === undefined) {
	// 	for (let i = 0; i < rows.length; i++) {
	// 		const row = rows[i] as GeneralResult

	// 		// Find distinct choice values
	// 		const sql = "SELECT DISTINCT choice_value FROM Choices WHERE app_id = ? AND event_name = ?"
	// 		const result = (await db.db.prepare(sql).bind(row.app_id, row.name).all()).results as Array<{ choice_value: string }>

	// 		// Patch row
	// 		(rows[i] as GeneralResult).possible_values = result.map(r => r.choice_value)
	// 	}
	// }

	// Return results
	return params.aggregate === undefined
		? rows as Array<GeneralResult>
		: rows[0] as CountAggregateResult
}
