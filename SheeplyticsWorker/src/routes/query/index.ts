import type { IRequest } from 'itty-router'

export async function ensureAuthenticated(request: IRequest, env: Env) {
	const isAuthenticated = request.headers.get('Authorization') === `Bearer ${env.QUERY_KEY}`
	if (!isAuthenticated) {
		return new Response('Unauthorized', { status: 401 })
	}
}

export { default as listEventsHandler } from './listEvents'
