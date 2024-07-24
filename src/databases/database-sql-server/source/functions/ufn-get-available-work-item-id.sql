CREATE FUNCTION [dbo].[ufn_GetAvailableWorkItemId]
(
    @MachineName NVARCHAR(MAX),
    @FlowName NVARCHAR(MAX),
    @MaxRetrieveCount SMALLINT
)
RETURNS BIGINT

AS
BEGIN
    DECLARE @WorkItemId BIGINT

    SELECT TOP(1)
        @WorkItemId = wi.[Id]
    FROM [WorkItem] wi
        INNER JOIN [Flow] f ON wi.[FlowId] = f.[Id]
        INNER JOIN [Machine] mch ON wi.[MachineId] = mch.[Id]
        INNER JOIN [Priority] p ON wi.[PriorityId] = p.[Id]
    WHERE
        wi.[Processed] = 0
        AND wi.[RetrieveCount] < @MaxRetrieveCount
        AND f.[Name] = @FlowName
        AND mch.[Name] = @MachineName
    -- 2 is treated higher than 1
    ORDER BY p.[Value] DESC

    RETURN @WorkItemId
END
GO