CREATE TABLE "Project" (
	"Id"	INTEGER NOT NULL,
	"ProjectNumber"	TEXT NOT NULL,
	"UserFriendlyProjectName"	TEXT NOT NULL,
	"InsertedAt" TEXT DEFAULT (strftime('%Y-%m-%d %H:%M.%f', 'now')),
	"UpdatedAt"	TEXT DEFAULT (strftime('%Y-%m-%d %H:%M.%f', 'now')),
	PRIMARY KEY("Id" AUTOINCREMENT)
);