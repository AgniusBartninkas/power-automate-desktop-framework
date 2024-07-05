CREATE TABLE "Flow" (
	"Id"	INTEGER NOT NULL,
	"Name"	TEXT NOT NULL,
	"ProjectId"	INTEGER NOT NULL,
	"InsertedAt" TEXT DEFAULT (strftime('%Y-%m-%d %H:%M.%f', 'now')),
	"UpdatedAt"	TEXT DEFAULT (strftime('%Y-%m-%d %H:%M.%f', 'now')),
	PRIMARY KEY("Id" AUTOINCREMENT)
);