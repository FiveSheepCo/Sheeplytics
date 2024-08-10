export type EventKind = 'flag' | 'action'
export type MetadataValue = string | number | boolean

export interface BaseEvent {
	name: string
	kind: EventKind
	appId: string
	userId: string
	timestamp: Date
	data: string
	metadata: Record<string, MetadataValue>
}

export interface TypedEvent<K extends EventKind = EventKind, T> extends Omit<BaseEvent, 'data' | 'kind'> {
	kind: K
	data: T
}

export type FlagEvent = TypedEvent<'flag', { value: boolean }>
export type ActionEvent = TypedEvent<'action', {}>
