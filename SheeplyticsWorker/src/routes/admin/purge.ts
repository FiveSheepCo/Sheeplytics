import type { IRequest } from "itty-router"
import Database from "../../database"

type PurgeRequest = {
	maxAge: string
}

type PurgeResponse = {
	count: number
}

type GetInactiveUsersRow = {
	user_id: string
}

async function getInactiveUsers(database: D1Database, maxAge: string): Promise<string[]> {
	const stmt = database.prepare(`SELECT user_id FROM Events GROUP BY user_id HAVING MAX(DATE(timestamp)) < DATE('now', ?)`).bind(maxAge)
	const results = await stmt.all<GetInactiveUsersRow>()
	return results.results.map(row => row.user_id)
}

function parseMaxAgeIntoSql(maxAge: string): string {

	// Parse maxAge into count and unit
	const [count, unit] = maxAge.split(' ')

	// Make sure the unit is actually an integer
	const countNum = Number.parseInt(count, 10)
	if (Number.isNaN(countNum)) {
		throw new Error('Invalid count in maxAge. Example: { "maxAge": "1 week" }')
	}

	// Make sure the unit is one of the allowed units
	type SqliteTimeUnit = "week" | "weeks" | "month" | "months" | "year" | "years"
	const allowedUnits = ["week", "weeks", "month", "months", "year", "years"]
	if (!allowedUnits.includes(unit)) {
		throw new Error(`Invalid unit in maxAge. Allowed units: ${allowedUnits.join(', ')}`)
	}

	// Map weeks to days, because SQLite doesn't have a week/weeks unit
	switch (unit as SqliteTimeUnit) {
		case "week":
		case "weeks":
			return `-${countNum * 7} days`
		default:
			return `-${countNum} ${unit}`
	}
}

export async function purge(database: D1Database, maxAge: string): Promise<number> {
	const maxAgeSql = parseMaxAgeIntoSql(maxAge)

	const inactiveUsers = await getInactiveUsers(database, maxAgeSql)
	const inactiveUsersList = inactiveUsers.map(user_id => `"${user_id}"`).join(', ')
	const stmt = database.prepare(`DELETE FROM Users WHERE user_id IN (${inactiveUsersList})`)
	await stmt.run()

	return inactiveUsers.length
}

/** Purge route for analytics events. */
export default async function handler(request: IRequest, env: Env): Promise<PurgeResponse> {

	// Parse body
	const body = await request.json() as Partial<PurgeRequest>
	if (body.maxAge === undefined) {
		throw new Error('maxAge is required. Example: { "maxAge": "1 week" }')
	}

	// Purge database
	const count = await purge(env.ANALYTICS_DB, body.maxAge)

	return {
		count
	}
}
