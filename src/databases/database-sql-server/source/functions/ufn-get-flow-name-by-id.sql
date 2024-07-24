CREATE FUNCTION [dbo].[ufn_GetFlowNameById]
(
    @Id SMALLINT
)
RETURNS NVARCHAR(MAX)

AS
BEGIN
    DECLARE @Name NVARCHAR(MAX)

    SELECT TOP(1) @Name = f.[Name] FROM [Flow] f WHERE f.[Id] = @Id

    RETURN @Name
END
GO