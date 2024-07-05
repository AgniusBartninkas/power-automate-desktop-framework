CREATE FUNCTION [dbo].[ufn_GetHighestPriorityWorkItemId]
(
    @MaxRetrieveCount SMALLINT
)
RETURNS BIGINT

AS
BEGIN
    DECLARE @WorkItemId BIGINT

    SELECT TOP(1)
        @WorkItemId = wi.[Id]
    FROM [WorkItem] wi
        INNER JOIN [Priority] p ON wi.[PriorityId] = p.[Id]
    WHERE
        wi.[Processed] = 0
        AND wi.[RetrieveCount] < @MaxRetrieveCount
    ORDER BY p.[Value] DESC
            ,wi.[InsertedAtUTC] ASC

    RETURN @WorkItemId
END
GO