CREATE FUNCTION [dbo].[ufn_GetConfigByProjectNumberAndProperty]
(
    @ProjectNumber NVARCHAR(MAX),
    @FlowName NVARCHAR(MAX),
    @PropertyName NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)

AS
BEGIN
    DECLARE @Id SMALLINT

    SELECT TOP(1) @Id = c.[Id] FROM [Config] c INNER JOIN [Project] p ON c.[ProjectId] = p.[Id] INNER JOIN [Flow] f ON c.[FlowId] = f.[Id] WHERE p.[ProjectNumber] = @ProjectNumber AND f.[Name] = @FlowName AND c.[PropertyName] = @PropertyName

    RETURN @Id
END
GO