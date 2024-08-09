import { AutoRouter } from 'itty-router'
import { ingest, query } from './routes'

const router = AutoRouter()

router
	.post('/ingest', ingest)
	.get('/query', query)

export default router
