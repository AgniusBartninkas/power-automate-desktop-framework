CREATE FUNCTION [dbo].[ufn_GetFlowId]
(
    @FlowName NVARCHAR(MAX),
	@ProjectId SMALLINT
)
RETURNS SMALLINT

AS
BEGIN
    DECLARE @FlowId SMALLINT

    SELECT TOP(1) @FlowId = f.[Id] FROM [Flow] f WHERE f.[Name] = @FlowName AND f.[ProjectId] = @ProjectId

    RETURN @FlowId
END
GO