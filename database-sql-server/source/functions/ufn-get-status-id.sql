CREATE FUNCTION [dbo].[ufn_GetStatusId]
(
    @Name NVARCHAR(255)
)
RETURNS SMALLINT

AS
BEGIN
    DECLARE @StatusId SMALLINT

    SELECT TOP(1) @StatusId = s.[Id] FROM [Status] s WHERE s.[Name] = @Name

    RETURN @StatusId
END
GO