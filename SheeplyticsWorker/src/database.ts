import { AppRow, BaseEvent, TypedEvent } from "./types";

export default class Database {
	constructor(readonly db: D1Database) {
	}

	async createAppIfNotExists(appId: string): Promise<void> {
		await this.db.prepare('INSERT OR IGNORE INTO Apps (app_id) VALUES (?)').bind(appId).run()
	}

	async createUserIfNotExists(userId: string, appId: string): Promise<void> {
		await this.db.prepare('INSERT OR IGNORE INTO Users (user_id, app_id) VALUES (?, ?)').bind(userId, appId).run()
	}

	async insertEvent<T>(event: TypedEvent<T>): Promise<void> {
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
	}

	async insertEventAs<T>(event: BaseEvent) {
		await this.insertEvent(event as TypedEvent<T>)
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
}
