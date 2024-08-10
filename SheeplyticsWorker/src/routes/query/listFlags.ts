import { IRequest } from "itty-router"

import Database from "../../database"
import { arraify } from "../../utils"

type AggregationKind = 'count'

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
		...buildMultiValueFilter(appIdFilter, 'flag.app_id'),
		...buildMultiValueFilter(userIdFilter, 'flag.user_id'),
		...buildMultiValueFilter(eventNameFilter, 'flag.event_name'),
	].join(' AND ')

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
		${whereClauses ? `WHERE ${whereClauses}` : ''}
		ORDER BY flag.flag_id ${order}
	`

	// Execute query
	const result = await db.db.prepare(query).bind(...queryBindings).all()
	const rows = Object.values(result.results)

	// Return results
	return params.aggregate === undefined ? rows : rows[0]
}
