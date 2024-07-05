CREATE TABLE Project
(
    [Id] SMALLINT PRIMARY KEY IDENTITY(1, 1) NOT NULL,
    [ProjectNumber] NVARCHAR(255) NOT NULL,
    [UserFriendlyProjectName] NVARCHAR(MAX) NOT NULL,
    [InsertedAtUTC] DATETIMEOFFSET(3) NOT NULL DEFAULT TODATETIMEOFFSET(GETUTCDATE(), 0),
    [UpdatedAtUTC] DATETIMEOFFSET(3) NOT NULL DEFAULT TODATETIMEOFFSET(GETUTCDATE(), 0)
)