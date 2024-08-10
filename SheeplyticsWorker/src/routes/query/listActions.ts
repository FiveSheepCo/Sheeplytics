import type { IRequest } from "itty-router"

import Database from "../../database"
import { arraify } from "../../utils"

type AggregationKind = 'count' | 'sum' | 'avg'

type QueryParams = {
	"filter[appId]"?: string
	"filter[userId]"?: string
	"filter[eventName]"?: string,
	"aggregate"?: AggregationKind,
	"order"?: "asc" | "desc",
}

/** Route for querying analytics data */
export default async function handler(request: IRequest, env: Env): Promise<any> {

	// Parse query parameters
	const params = request.query as QueryParams
	const appIdFilter = arraify(params['filter[appId]'])
	const userIdFilter = arraify(params['filter[userId]'])
	const eventNameFilter = arraify(params['filter[eventName]'])
	const order = params.order?.toUpperCase() ?? 'DESC'

	// Create database connection
	const db = new Database(env.ANALYTICS_DB)

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
		...buildMultiValueFilter(appIdFilter, 'action.app_id'),
		...buildMultiValueFilter(userIdFilter, 'action.user_id'),
		...buildMultiValueFilter(eventNameFilter, 'action.event_name'),
	].join(' AND ')

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
		${whereClauses ? `WHERE ${whereClauses}` : ''}
		ORDER BY action.action_id ${order}
	`

	// Execute query
	const result = await db.db.prepare(query).bind(...queryBindings).all()
	const rows = Object.values(result.results)

	// Return results
	return params.aggregate === undefined ? rows : rows[0]
}
