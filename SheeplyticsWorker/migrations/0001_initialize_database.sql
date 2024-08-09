-- Migration number: 0001 	 2024-08-06T18:40:33.222Z

CREATE TABLE Apps (
    app_id TEXT PRIMARY KEY
);

CREATE TABLE Users (
    user_id TEXT PRIMARY KEY,
    app_id TEXT NOT NULL,
    FOREIGN KEY (app_id) REFERENCES Apps(app_id)
);

CREATE TABLE Events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    kind TEXT NOT NULL,
	inner_data TEXT NOT NULL,
	metadata TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
