import { ActionEvent, ActionRow, AppRow, BaseEvent, FlagEvent, FlagRow, TypedEvent } from "./types"

function bufToHex(buffer: ArrayBuffer): string {
	return Array.from(new Uint8Array(buffer)).map(b => b.toString(16).padStart(2, '0')).join('')
}

async function eventIdentifier(event: BaseEvent): Promise<string> {
	const identifier = `${event.appId}${event.userId}${event.name}`
	const digest = await crypto.subtle.digest({ name: 'SHA-256' }, new TextEncoder().encode(identifier))
	return bufToHex(digest)
}

export default class Database {
	constructor(readonly db: D1Database) {
	}

	async createAppIfNotExists(appId: string): Promise<void> {
		await this.db.prepare('INSERT OR IGNORE INTO Apps (app_id) VALUES (?)').bind(appId).run()
	}

	async createUserIfNotExists(userId: string, appId: string): Promise<void> {
		await this.db.prepare('INSERT OR IGNORE INTO Users (user_id, app_id) VALUES (?, ?)').bind(userId, appId).run()
	}

	async insertEvent<T>(event: TypedEvent<any, T>): Promise<void> {
		await this.createAppIfNotExists(event.appId)
		await this.createUserIfNotExists(event.userId, event.appId)
		await this.db.prepare('INSERT INTO Events (user_id, name, kind, inner_data, metadata, timestamp) VALUES (?, ?, ?, ?, ?, ?)')
			.bind(
				event.userId,
				event.name,
				event.kind,
				JSON.stringify(event.data),
				JSON.stringify(event.metadata),
				event.timestamp.toISOString()
			)
			.run()

		switch (event.kind) {
			case 'action': {
				await this._incrementActionCount(event as ActionEvent)
				break
			}
			case 'flag': {
				await this._setFlagValue(event as FlagEvent)
				break
			}
		}
	}

	async insertEventAs<T>(event: BaseEvent) {
		await this.insertEvent(event as TypedEvent<any, T>)
	}

	async listApps(): Promise<Array<AppRow>> {
		const result = await this.db.prepare('SELECT app_id FROM Apps').all()
		return Object.values(result.results) as Array<unknown> as Array<AppRow>
	}

	async clear(): Promise<void> {
		await this.db.prepare('DELETE FROM Events').run()
		await this.db.prepare('DELETE FROM Users').run()
		await this.db.prepare('DELETE FROM Apps').run()
	}

	async _incrementActionCount(event: ActionEvent) {
		const existingAction: ActionRow | null = await this.db.prepare('SELECT action_id FROM Actions WHERE app_id = ? AND user_id = ? AND event_name = ?')
			.bind(event.appId, event.userId, event.name)
			.first()
		if (existingAction) {
			await this.db.prepare('UPDATE Actions SET trigger_count = trigger_count + 1 WHERE action_id = ?')
				.bind(existingAction.action_id)
				.run()
		} else {
			await this.db.prepare('INSERT INTO Actions (app_id, user_id, event_name, trigger_count) VALUES (?, ?, ?, 1)')
				.bind(event.appId, event.userId, event.name)
				.run()
		}
	}

	async _setFlagValue(event: FlagEvent) {
		const existingFlag: FlagRow | null = await this.db.prepare('SELECT flag_id FROM Flags WHERE app_id = ? AND user_id = ? AND event_name = ?')
			.bind(event.appId, event.userId, event.name)
			.first()
		if (existingFlag) {
			await this.db.prepare('UPDATE Flags SET is_active = ? WHERE flag_id = ?')
				.bind(event.data.value ? 1 : 0, existingFlag.flag_id)
				.run()
		} else {
			await this.db.prepare('INSERT INTO Flags (app_id, user_id, event_name, is_active) VALUES (?, ?, ?, ?)')
				.bind(event.appId, event.userId, event.name, event.data.value ? 1 : 0)
				.run()
		}
	}
}
