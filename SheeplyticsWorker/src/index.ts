import { AutoRouter } from 'itty-router'
import { debug, ingest, query, admin } from './routes'

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

export default router
