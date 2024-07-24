CREATE VIEW [dbo].[uvw_WorkItemsReport] AS
SELECT 
    wi.[Id]
    ,wid.[DataContent]
    ,wid.[DataSource]
    ,p.[ProjectNumber]
    ,p.[UserFriendlyProjectName]
    ,mch.[Name] 'MachineName'
    ,f.[Name] 'FlowName'
    ,s.[Name] 'Status'
    ,pr.[Name] 'Priority'
    ,wir.[Reason]
    ,wir.[Message]
    ,[dbo].[ufn_GetProcessingTimeInSeconds](wir.[ProcessingStartUTC], wir.[ProcessingEndUTC]) 'AccumulatedRunTimeInSeconds'
    ,wir.[ProcessingStartUTC]
    ,wir.[ProcessingEndUTC]
FROM [WorkItem] wi
INNER JOIN [WorkItemData] wid ON wi.[Id] = wid.[WorkItemId]
INNER JOIN [WorkItemResult] wir ON wi.[Id] = wir.[WorkItemId]
INNER JOIN [Status] s ON wi.[StatusId] = s.[Id]
INNER JOIN [Machine] mch ON wir.[MachineId] = mch.[Id]
INNER JOIN [Flow] f ON wir.[FlowId] = f.[Id]
INNER JOIN [Project] p ON f.[ProjectId] = p.[Id]
INNER JOIN [Priority] pr ON wi.[PriorityId] = pr.[Id]