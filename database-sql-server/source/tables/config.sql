CREATE TABLE Config
(
    [Id] SMALLINT PRIMARY KEY IDENTITY(1, 1) NOT NULL,
    [ProjectId] SMALLINT NOT NULL,
    [FlowId] SMALLINT NULL,
    [PropertyName] NVARCHAR(255) NOT NULL,
    [Value] NVARCHAR(255) NOT NULL,
    [DataType] NVARCHAR(50) NOT NULL,
    [InsertedAtUTC] DATETIMEOFFSET(3) NOT NULL DEFAULT TODATETIMEOFFSET(GETUTCDATE(), 0),
    [UpdatedAtUTC] DATETIMEOFFSET(3) NOT NULL DEFAULT TODATETIMEOFFSET(GETUTCDATE(), 0)
)
