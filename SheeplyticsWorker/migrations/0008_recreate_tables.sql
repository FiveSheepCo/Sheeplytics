-- Migration number: 0008 	 2024-10-23T07:31:08.258Z

-- Defer foreign key enforcement in this transaction

PRAGMA defer_foreign_keys = on;

-- Rename tables

ALTER TABLE Users RENAME TO Users_TEMP;
ALTER TABLE Events RENAME TO Events_TEMP;
ALTER TABLE Actions RENAME TO Actions_TEMP;
ALTER TABLE Flags RENAME TO Flags_TEMP;
ALTER TABLE JsonValues RENAME TO JsonValues_TEMP;
ALTER TABLE ActionsEventHistory RENAME TO ActionsEventHistory_TEMP;
ALTER TABLE FlagsEventHistory RENAME TO FlagsEventHistory_TEMP;
ALTER TABLE JsonValuesEventHistory RENAME TO JsonValuesEventHistory_TEMP;

-- Create new tables with proper foreign key constraints

CREATE TABLE Users (
    user_id TEXT PRIMARY KEY,
    app_id TEXT NOT NULL,
    FOREIGN KEY (app_id) REFERENCES Apps(app_id) ON DELETE CASCADE
);

CREATE TABLE Events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
	name TEXT NOT NULL,
    kind TEXT NOT NULL,
	inner_data TEXT NOT NULL,
	metadata TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE Actions (
	action_id INTEGER PRIMARY KEY AUTOINCREMENT,
	app_id TEXT NOT NULL,
	user_id TEXT NOT NULL,
	event_name TEXT NOT NULL,
	trigger_count INTEGER NOT NULL DEFAULT 0,
	FOREIGN KEY (app_id) REFERENCES Apps(app_id) ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE Flags (
	flag_id INTEGER PRIMARY KEY AUTOINCREMENT,
	app_id TEXT NOT NULL,
	user_id TEXT NOT NULL,
	event_name TEXT NOT NULL,
	is_active BOOLEAN NOT NULL,
	FOREIGN KEY (app_id) REFERENCES Apps(app_id) ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE JsonValues (
	value_id INTEGER PRIMARY KEY AUTOINCREMENT,
	app_id TEXT NOT NULL,
	user_id TEXT NOT NULL,
	event_name TEXT NOT NULL,
	json_value TEXT NOT NULL,
	FOREIGN KEY (app_id) REFERENCES Apps(app_id) ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE FlagsEventHistory (
	history_entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
	flag_id INTEGER NOT NULL,
	event_id INTEGER NOT NULL,
	FOREIGN KEY (flag_id) REFERENCES Flags(flag_id) ON DELETE CASCADE,
	FOREIGN KEY (event_id) REFERENCES Events(event_id) ON DELETE CASCADE
);

CREATE TABLE ActionsEventHistory (
	history_entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
	action_id INTEGER NOT NULL,
	event_id INTEGER NOT NULL,
	FOREIGN KEY (action_id) REFERENCES Actions(action_id) ON DELETE CASCADE,
	FOREIGN KEY (event_id) REFERENCES Events(event_id) ON DELETE CASCADE
);

CREATE TABLE JsonValuesEventHistory (
	history_entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
	value_id INTEGER NOT NULL,
	event_id INTEGER NOT NULL,
	FOREIGN KEY (value_id) REFERENCES JsonValues(value_id) ON DELETE CASCADE,
	FOREIGN KEY (event_id) REFERENCES Events(event_id) ON DELETE CASCADE
);

-- Move data from temp tables to new tables

INSERT INTO Users (user_id, app_id)
SELECT user_id, app_id
FROM Users_TEMP;

INSERT INTO Events (event_id, user_id, name, kind, inner_data, metadata, timestamp)
SELECT event_id, user_id, name, kind, inner_data, metadata, timestamp
FROM Events_TEMP;

INSERT INTO Actions (action_id, app_id, user_id, event_name, trigger_count)
SELECT action_id, app_id, user_id, event_name, trigger_count
FROM Actions_TEMP;

INSERT INTO Flags (flag_id, app_id, user_id, event_name, is_active)
SELECT flag_id, app_id, user_id, event_name, is_active
FROM Flags_TEMP;

INSERT INTO JsonValues (value_id, app_id, user_id, event_name, json_value)
SELECT value_id, app_id, user_id, event_name, json_value
FROM JsonValues_TEMP;

INSERT INTO ActionsEventHistory (history_entry_id, action_id, event_id)
SELECT history_entry_id, action_id, event_id
FROM ActionsEventHistory_TEMP;

INSERT INTO FlagsEventHistory (history_entry_id, flag_id, event_id)
SELECT history_entry_id, flag_id, event_id
FROM FlagsEventHistory_TEMP;

INSERT INTO JsonValuesEventHistory (history_entry_id, value_id, event_id)
SELECT history_entry_id, value_id, event_id
FROM JsonValuesEventHistory_TEMP;

-- Delete temp tables

DROP TABLE Users_TEMP;
DROP TABLE Events_TEMP;
DROP TABLE Actions_TEMP;
DROP TABLE Flags_TEMP;
DROP TABLE JsonValues_TEMP;
DROP TABLE ActionsEventHistory_TEMP;
DROP TABLE FlagsEventHistory_TEMP;
DROP TABLE JsonValuesEventHistory_TEMP;

-- Reenable foreign key constraint checks

PRAGMA defer_foreign_keys = off;
