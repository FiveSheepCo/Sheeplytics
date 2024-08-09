import { EventKind } from "./event"

export type JsonString = string

export interface AppRow {
	app_id: string
}

export interface UserRow {
	user_id: string
	app_id: string
}

export interface EventRow {
	event_id: number
	user_id: string
	kind: EventKind
	inner_data: JsonString
	metadata: JsonString
	timestamp: Date
}
