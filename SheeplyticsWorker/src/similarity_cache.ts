import type { EventKind, TypedEvent } from "./types"

export default class SimilarityCache {
	static expirationTtl = 60 * 60 * 24

	constructor(readonly cache: KVNamespace) {
	}

	static async signature(event: TypedEvent<EventKind, unknown>): Promise<string> {
		const textEncoder = new TextEncoder()
		const content = {
			appId: event.appId,
			userId: event.userId,
			name: event.name,
			kind: event.kind,
			data: event.data
		}
		const encodedContent = textEncoder.encode(JSON.stringify(content))
		const buffer = await crypto.subtle.digest('SHA-256', encodedContent)
		const bytes = new Uint8Array(buffer)
		const signature = Array.from(bytes)
			.map(b => b.toString(16).padStart(2, '0'))
			.join('')
		return signature
	}

	async exists(event: TypedEvent<EventKind, unknown>): Promise<boolean> {
		const signature = await SimilarityCache.signature(event)
		const cachedEntry = await this.cache.get(signature)
		return cachedEntry !== null
	}

	async put(event: TypedEvent<EventKind, unknown>): Promise<void> {
		const signature = await SimilarityCache.signature(event)
		await this.cache.put(signature, '1', { expirationTtl: SimilarityCache.expirationTtl })
	}
}
