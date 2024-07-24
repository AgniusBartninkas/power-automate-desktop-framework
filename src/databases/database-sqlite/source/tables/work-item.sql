CREATE TABLE "WorkItem" (
	"Id"	INTEGER NOT NULL,
	"Number"	TEXT NOT NULL,
	"StatusId"	INTEGER NULL,
	"FlowId"	INTEGER NOT NULL,
	"PriorityId"	INTEGER NOT NULL,
	"ProcessedBy"	TEXT NULL,
	"RetrieveCount"	INTEGER DEFAULT 0,
	"ValueGained"	INTEGER NULL,
	"Processed"	INTEGER DEFAULT 0,
	"IsValueGainedCalculated"	INTEGER DEFAULT 0,
	"AccumulatedRunTime"	INTEGER DEFAULT 0,
	"InsertedAt"	TEXT DEFAULT (strftime('%Y-%m-%d %H:%M.%f', 'now')),
	"UpdatedAt"	TEXT DEFAULT (strftime('%Y-%m-%d %H:%M.%f', 'now')),
	CONSTRAINT "FK_WorkItem_Status" FOREIGN KEY("StatusId") REFERENCES "Status"("Id") ON DELETE CASCADE,
	CONSTRAINT "FK_WorkItem_Flow" FOREIGN KEY("FlowId") REFERENCES "Flow"("Id") ON DELETE CASCADE,
	CONSTRAINT "FK_WorkItem_Priority" FOREIGN KEY("PriorityId") REFERENCES "Priority"("Id") ON DELETE CASCADE,
	PRIMARY KEY("Id" AUTOINCREMENT)
);