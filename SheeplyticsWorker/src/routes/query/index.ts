import type { IRequest } from 'itty-router'

export async function ensureAuthenticated(request: IRequest, env: Env) {
	const isAuthenticated = request.headers.get('Authorization') === `Bearer ${env.QUERY_KEY}`
	if (!isAuthenticated) {
		return new Response('Unauthorized', { status: 401 })
	}
}

export { default as listEventsHandler } from './listEvents'
export { default as listFlagsHandler } from './listFlags'
export { default as listActionsHandler } from './listActions'
export { default as listChoicesHandler } from './listChoices'
export { default as listValuesHandler } from './listValues'
