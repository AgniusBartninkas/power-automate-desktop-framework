CREATE FUNCTION [dbo].[ufn_GetPriorityId]
(
    @Name NVARCHAR(255)
)
RETURNS SMALLINT

AS
BEGIN
    DECLARE @PriorityId SMALLINT

    SELECT TOP(1) @PriorityId = p.[Id] FROM [Priority] p WHERE p.[Name] = @Name

    RETURN @PriorityId
END
GO