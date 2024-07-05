CREATE FUNCTION [dbo].[ufn_GetProjectId]
(
    @Name NVARCHAR(255)
)
RETURNS SMALLINT

AS
BEGIN
    DECLARE @ProjectId SMALLINT

    SELECT TOP(1) @ProjectId = p.[Id] FROM [Project] p WHERE p.[ProjectNumber] = @Name

    RETURN @ProjectId
END
GO