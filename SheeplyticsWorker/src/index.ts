import { AutoRouter } from 'itty-router'
import { debug, ingest, query } from './routes'

// Debug routes
const debugRouter = AutoRouter({base: '/debug'})
	.post('/clear', debug.clearDatabaseHandler)

// Production routes
const router = AutoRouter()
	.all('/debug/*', debug.ensureDevEnv, debugRouter.fetch)
	.post('/ingest', ingest)
	.get('/query', query)

export default router
