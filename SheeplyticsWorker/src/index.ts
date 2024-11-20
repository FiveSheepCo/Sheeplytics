import { AutoRouter, type IRequest } from 'itty-router'
import { debug, ingest, query, admin } from './routes'
import { purge } from './routes/admin/purge'

// Debug router
const debugRouter = AutoRouter({base: '/debug'})
	.post('/clear', debug.clearDatabaseHandler)

// Query router
const queryRouter = AutoRouter({base: '/query'})
	.get('/events', query.listEventsHandler)
	.get('/actions', query.listActionsHandler)
	.get('/flags', query.listFlagsHandler)
	.get('/choices', query.listChoicesHandler)
	.get('/values', query.listValuesHandler)

// Admin router
const adminRouter = AutoRouter({base: '/admin'})
	.post('/purge', admin.purgeHandler)

// General router
const router = AutoRouter()
	.all('/debug/*', debug.ensureDevEnv, debugRouter.fetch)
	.all('/query/*', query.ensureAuthenticated, queryRouter.fetch)
	.all('/admin/*', admin.ensureAuthenticated, adminRouter.fetch)
	.post('/ingest', ingest)

// Scheduled request via Cloudflare trigger
export async function scheduled(_request: IRequest, env: Env) {
	const purgedUserCount = await purge(env.ANALYTICS_DB, '2 weeks')
	console.log(`Purged ${purgedUserCount} inactive users.`)
	return {
		status: 'success',
		operation: 'cleanup',
		data: {
			purgedUserCount
		}
	}
}

export default { scheduled, ...router }
