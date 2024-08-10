import { AutoRouter } from 'itty-router'
import { debug, ingest, query } from './routes'

// Debug router
const debugRouter = AutoRouter({base: '/debug'})
	.post('/clear', debug.clearDatabaseHandler)

// Query router
const queryRouter = AutoRouter({base: '/query'})
	.get('/events', query.listEventsHandler)

// General router
const router = AutoRouter()
	.all('/debug/*', debug.ensureDevEnv, debugRouter.fetch)
	.all('/query/*', query.ensureAuthenticated, queryRouter.fetch)
	.post('/ingest', ingest)

export default router
