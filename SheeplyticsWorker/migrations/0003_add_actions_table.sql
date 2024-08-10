-- Migration number: 0003 	 2024-08-09T23:41:35.787Z

CREATE TABLE Actions (
	action_id INTEGER PRIMARY KEY AUTOINCREMENT,
	app_id TEXT NOT NULL,
	user_id TEXT NOT NULL,
	event_name TEXT NOT NULL,
	trigger_count INTEGER NOT NULL DEFAULT 0
);
