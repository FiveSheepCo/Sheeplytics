import { StatusError } from "itty-router"
import Database from "../database"

type DebugResponse = {
	message: string
	status: number
}

export async function ensureDevEnv(_: Request, env: Env) {
	if (env.IS_DEVELOPMENT_MODE !== 'true') {
		throw new StatusError(403, 'Forbidden')
	}
}

export async function clearDatabaseHandler(_: Request, env: Env): Promise<DebugResponse> {
	const db = new Database(env.ANALYTICS_DB)
	await db.clear()
	return {
		message: 'ok',
		status: 200,
	}
}
