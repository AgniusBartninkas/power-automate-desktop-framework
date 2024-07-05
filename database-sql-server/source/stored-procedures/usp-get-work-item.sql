CREATE PROCEDURE [dbo].[usp_GetWorkItem]
    @MachineName NVARCHAR(MAX),
    @FlowName NVARCHAR(MAX),
    @MaxRetrieveCount SMALLINT

AS
BEGIN
    DECLARE @Status SMALLINT
            ,@Message NVARCHAR(MAX)
    BEGIN TRY
        BEGIN TRANSACTION
        SET NOCOUNT ON
        -- on stored procedure fatal, rollbacks transaction so it is not kept alive
        SET XACT_ABORT ON

        DECLARE @Result INT
                ,@WorkItemId BIGINT
                ,@StatusId SMALLINT
                ,@MachineId SMALLINT
                ,@InsertedAtUTC DATETIMEOFFSET(3)
                ,@UpdatedAtUTC DATETIMEOFFSET(3)
        -- try to lock stored procedure exclusively, wait for 30s
        EXEC @Result = sp_getapplock @Resource = 'usp_GetWorkItem', @LockMode = 'Exclusive', @LockTimeout = 30000, @LockOwner = 'Transaction'

        IF @Result < 0
        BEGIN
            SET @Status = -2
            SET @Message = N'Failed to lock stored procedure usp_GetWorkItem exclusively'
            ;THROW 51000, @Message, 1
        END

        SET @InsertedAtUTC = [dbo].[ufn_GetUTCDate]()
        SET @UpdatedAtUTC = @InsertedAtUTC
        SET @WorkItemId = [dbo].[ufn_GetAvailableWorkItemId](@MachineName, @FlowName, @MaxRetrieveCount)
        SET @StatusId = [dbo].[ufn_GetStatusId]('InProgress')
        SET @MachineId = [dbo].[ufn_GetMachineId](@MachineName)

		IF @StatusId IS NULL
        BEGIN
            SET @Status = -3
            SET @Message = N'Could not find status InProgress in Status table'
            ;THROW 51000, @Message, 1
        END
        ELSE IF @MachineId IS NULL
        BEGIN
            SET @Status = -4
            SET @Message = N'Could not find machine with name ' + @MachineName + ' in Machine table'
            ;THROW 51000, @Message, 1
        END
        ELSE IF @WorkItemId IS NULL
        BEGIN
            SET @Status = 1
            SET @Message = N'No available work items for Flow ' + @FlowName + ' and machine ' + @MachineName
            ;THROW 51000, @Message, 1
        END
        
        UPDATE [WorkItem]
        SET
            [RetrieveCount] = [RetrieveCount] + 1,
            [MachineId] = @MachineId,
            [UpdatedAtUTC] = @UpdatedAtUTC
        WHERE 
            [Id] = @WorkItemId

        -- separate update for status
        UPDATE wi
        SET
            [StatusId] = @StatusId
        FROM [WorkItem] wi
        INNER JOIN [Status] s ON wi.[StatusId] = s.[Id]
        WHERE 
            wi.[Id] = @WorkItemId
            AND s.[Name] IN ('InProgress', 'ToDo', 'Success')

        SET @Status = 0
        SET @Message = N'Successfully retrieved work item with id ' + CAST(@WorkItemId AS NVARCHAR) + ' and locked it for machine ' + @MachineName

        COMMIT TRANSACTION

        SELECT @WorkItemId 'WorkItemId', wi.[Number], wi.[RetrieveCount], wid.[DataContent], wid.[DataSource], s.[Name] 'WorkItemStatus', @Status 'Status', @Message 'Message'
        FROM [WorkItem] wi INNER JOIN [WorkItemData] wid ON wi.[Id] = wid.[WorkItemId] INNER JOIN [Status] s ON wi.[StatusId] = s.[Id]
        WHERE wi.[Id] = @WorkItemId
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
        ROLLBACK TRANSACTION
        END

        IF @Status IS NULL
        BEGIN
            SET @Status = -1
        END

        SELECT @Status 'Status', ERROR_MESSAGE() 'Message'
    END CATCH
END