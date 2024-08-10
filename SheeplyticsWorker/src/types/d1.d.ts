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

export interface ActionRow {
	action_id: number
	app_id: string
	user_id: string
	event_name: string
	trigger_count: number
}

export interface FlagRow {
	flag_id: number
	app_id: string
	user_id: string
	event_name: string
	is_active: boolean
}
