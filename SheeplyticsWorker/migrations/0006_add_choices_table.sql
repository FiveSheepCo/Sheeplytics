-- Migration number: 0006 	 2024-08-21T07:55:00.000Z

CREATE TABLE Choices (
	choice_id INTEGER PRIMARY KEY AUTOINCREMENT,
	app_id TEXT NOT NULL,
	user_id TEXT NOT NULL,
	event_name TEXT NOT NULL,
	choice_value TEXT NOT NULL
);

CREATE TABLE ChoicesEventHistory (
	history_entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
	choice_id INTEGER NOT NULL,
	event_id INTEGER NOT NULL
);
