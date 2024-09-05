export type EventKind = 'flag' | 'action' | 'choice' | 'value'
export type JsonValue = string | number | boolean | Array<MetadataValue>

export interface BaseEvent {
	name: string
	kind: EventKind
	appId: string
	userId: string
	timestamp: string
	data: string
	metadata: Record<string, JsonValue>
}

export interface TypedEvent<K extends EventKind = EventKind, T> extends Omit<BaseEvent, 'data' | 'kind'> {
	kind: K
	data: T
}

export type FlagEvent = TypedEvent<'flag', { value: boolean }>
export type ActionEvent = TypedEvent<'action', Record<string, never>>
export type ChoiceEvent = TypedEvent<'choice', { value: string }>
export type ValueEvent = TypedEvent<'value', { value: JsonValue }>
