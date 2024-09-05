-- Migration number: 0007 	 2024-09-05T15:39:00.000Z

CREATE TABLE JsonValues (
	value_id INTEGER PRIMARY KEY AUTOINCREMENT,
	app_id TEXT NOT NULL,
	user_id TEXT NOT NULL,
	event_name TEXT NOT NULL,
	json_value TEXT NOT NULL
);

CREATE TABLE JsonValuesEventHistory (
	history_entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
	value_id INTEGER NOT NULL,
	event_id INTEGER NOT NULL
);
