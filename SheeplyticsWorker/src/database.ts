import type { ActionEvent, ActionRow, AppRow, BaseEvent, ChoiceEvent, ChoiceRow, EventKind, FlagEvent, FlagRow, TypedEvent } from "./types"

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

	async insertEvent(event: TypedEvent<EventKind, unknown>): Promise<void> {
		await this.createAppIfNotExists(event.appId)
		await this.createUserIfNotExists(event.userId, event.appId)

		const result = await this.db
			.prepare('INSERT INTO Events (user_id, name, kind, inner_data, metadata, timestamp) VALUES (?, ?, ?, ?, ?, ?)')
			.bind(
				event.userId,
				event.name,
				event.kind,
				JSON.stringify(event.data),
				JSON.stringify(event.metadata),
				event.timestamp
			)
			.run()

		const eventId = result.meta.last_row_id

		switch (event.kind) {
			case 'action': {
				await this._incrementActionCount(event as ActionEvent, eventId)
				break
			}
			case 'flag': {
				await this._setFlagValue(event as FlagEvent, eventId)
				break
			}
			case 'choice': {
				await this._setChoiceValue(event as ChoiceEvent, eventId)
				break
			}
		}
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

	async _incrementActionCount(event: ActionEvent, eventId: number) {

		// Check if the action already exists
		const existingAction: ActionRow | null = await this.db.prepare('SELECT action_id FROM Actions WHERE app_id = ? AND user_id = ? AND event_name = ?')
			.bind(event.appId, event.userId, event.name)
			.first()

		if (existingAction) {

			// Increment action trigger count
			await this.db.prepare('UPDATE Actions SET trigger_count = trigger_count + 1 WHERE action_id = ?')
				.bind(existingAction.action_id)
				.run()

			// Create history entry
			await this.db.prepare('INSERT INTO ActionsEventHistory (action_id, event_id) VALUES (?, ?)')
				.bind(existingAction.action_id, eventId)
				.run()
		} else {

			// Create new action
			const { meta } = await this.db.prepare('INSERT INTO Actions (app_id, user_id, event_name, trigger_count) VALUES (?, ?, ?, 1)')
				.bind(event.appId, event.userId, event.name)
				.run()

			// Create history entry
			const actionId = meta.last_row_id
			await this.db.prepare('INSERT INTO ActionsEventHistory (action_id, event_id) VALUES (?, ?)')
				.bind(actionId, eventId)
				.run()
		}
	}

	async _setFlagValue(event: FlagEvent, eventId: number) {

		// Check if the flag already exists
		const existingFlag: FlagRow | null = await this.db.prepare('SELECT flag_id FROM Flags WHERE app_id = ? AND user_id = ? AND event_name = ?')
			.bind(event.appId, event.userId, event.name)
			.first()

		if (existingFlag) {

			// Update flag value
			await this.db.prepare('UPDATE Flags SET is_active = ? WHERE flag_id = ?')
				.bind(event.data.value ? 1 : 0, existingFlag.flag_id)
				.run()

			// Create history entry
			await this.db.prepare('INSERT INTO FlagsEventHistory (flag_id, event_id) VALUES (?, ?)')
				.bind(existingFlag.flag_id, eventId)
				.run()
		} else {

			// Create new flag
			const { meta } = await this.db.prepare('INSERT INTO Flags (app_id, user_id, event_name, is_active) VALUES (?, ?, ?, ?)')
				.bind(event.appId, event.userId, event.name, event.data.value ? 1 : 0)
				.run()

			// Create history entry
			const flagId = meta.last_row_id
			await this.db.prepare('INSERT INTO FlagsEventHistory (flag_id, event_id) VALUES (?, ?)')
				.bind(flagId, eventId)
				.run()
		}
	}

	async _setChoiceValue(event: ChoiceEvent, eventId: number) {

		// Check if the choice already exists
		const existingChoice: ChoiceRow | null = await this.db.prepare('SELECT choice_id FROM Choices WHERE app_id = ? AND user_id = ? AND event_name = ?')
			.bind(event.appId, event.userId, event.name)
			.first()

		if (existingChoice) {

			// Update choice value
			await this.db.prepare('UPDATE Choices SET choice_value = ? WHERE choice_id = ?')
				.bind(event.data.value, existingChoice.choice_id)
				.run()

			// Create history entry
			await this.db.prepare('INSERT INTO ChoicesEventHistory (choice_id, event_id) VALUES (?, ?)')
				.bind(existingChoice.choice_id, eventId)
				.run()
		} else {

			// Create new choice
			const { meta } = await this.db.prepare('INSERT INTO Choices (app_id, user_id, event_name, choice_value) VALUES (?, ?, ?, ?)')
				.bind(event.appId, event.userId, event.name, event.data.value)
				.run()

			// Create history entry
			const choiceId = meta.last_row_id
			await this.db.prepare('INSERT INTO ChoicesEventHistory (choice_id, event_id) VALUES (?, ?)')
				.bind(choiceId, eventId)
				.run()
		}
	}
}
