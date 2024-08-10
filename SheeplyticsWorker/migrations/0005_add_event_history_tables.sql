-- Migration number: 0005 	 2024-08-10T19:09:07.508Z

CREATE TABLE FlagsEventHistory (
	history_entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
	flag_id INTEGER NOT NULL,
	event_id INTEGER NOT NULL
);

CREATE TABLE ActionsEventHistory (
	history_entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
	action_id INTEGER NOT NULL,
	event_id INTEGER NOT NULL
);
