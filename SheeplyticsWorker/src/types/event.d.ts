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

export interface TypedEvent<T> extends Omit<BaseEvent, 'data'> {
	data: T
}

export type FlagEvent = TypedEvent<{ value: boolean }>
export type ActionEvent = TypedEvent<{}>
