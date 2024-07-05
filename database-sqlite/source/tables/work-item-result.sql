CREATE TABLE "WorkItemResult" (
    "Id" INTEGER NOT NULL,
    "WorkItemId" INTEGER NULL, 
    "StatusId" INTEGER NOT NULL, 
    "FlowId" INTEGER NOT NULL, 
    "Reason" TEXT NULL, 
    "Message" TEXT NOT NULL, 
    "InsertedAt" TEXT DEFAULT (strftime('%Y-%m-%d %H:%M.%f', 'now')),
    CONSTRAINT "FK_WorkItemResult_WorkItem" FOREIGN KEY("WorkItemId") REFERENCES "WorkItem"("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_WorkItemResult_Status" FOREIGN KEY("StatusId") REFERENCES "Status"("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_WorkItemResult_Flow" FOREIGN KEY("FlowId") REFERENCES "Flow"("Id") ON DELETE CASCADE,  
    PRIMARY KEY("Id" AUTOINCREMENT)
)