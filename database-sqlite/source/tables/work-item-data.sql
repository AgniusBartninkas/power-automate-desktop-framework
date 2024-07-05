CREATE TABLE "WorkItemData" (
	"Id"	INTEGER NOT NULL,
	"WorkItemId"	INTEGER NOT NULL,
	"DataContent"	BLOB NOT NULL,
	"DataSource"	TEXT NOT NULL,
	"InsertedAt"	TEXT DEFAULT (strftime('%Y-%m-%d %H:%M.%f', 'now')),
	"UpdatedAt"	TEXT DEFAULT (strftime('%Y-%m-%d %H:%M.%f', 'now')),
	CONSTRAINT "FK_WorkItemData_WorkItem" FOREIGN KEY("WorkItemId") REFERENCES "WorkItem"("Id") ON DELETE CASCADE,
	PRIMARY KEY("Id" AUTOINCREMENT)
);