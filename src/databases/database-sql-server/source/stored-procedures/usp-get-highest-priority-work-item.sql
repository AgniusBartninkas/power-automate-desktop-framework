CREATE PROCEDURE [dbo].[usp_GetHighestPriorityWorkItem]
    @Environment NVARCHAR(255),
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
                ,@AvailableMachineId SMALLINT
                ,@FlowName NVARCHAR(MAX)
                ,@MachineName NVARCHAR(MAX)
                ,@ProjectNumber NVARCHAR(MAX)
                ,@ProjectId INT
                ,@UserFriendlyName NVARCHAR(MAX)
                ,@Environments NVARCHAR(255)
                ,@InsertedAtUTC DATETIMEOFFSET(3)
                ,@UpdatedAtUTC DATETIMEOFFSET(3)
        -- try to lock stored procedure exclusively, wait for 30s
        EXEC @Result = sp_getapplock @Resource = 'usp_GetHighestPriorityWorkItem', @LockMode = 'Exclusive', @LockTimeout = 30000, @LockOwner = 'Transaction'

        IF @Result < 0
        BEGIN
            SET @Status = -2
            SET @Message = N'Failed to lock stored procedure usp_GetHighestPriorityWorkItem exclusively'
            ;THROW 51000, @Message, 1
        END

        SET @InsertedAtUTC = [dbo].[ufn_GetUTCDate]()
        SET @UpdatedAtUTC = @InsertedAtUTC
        SET @WorkItemId = [dbo].[ufn_GetHighestPriorityWorkItemId](@MaxRetrieveCount)

        SELECT TOP(1) @FlowName = f.[Name] FROM [Flow] f INNER JOIN [WorkItem] wi ON f.[Id] = wi.[FlowId] WHERE wi.[Id] = @WorkItemId
        SELECT TOP(1) @ProjectNumber = p.[ProjectNumber] FROM [Project] p INNER JOIN [Flow] f ON p.[Id] = f.[ProjectId] INNER JOIN [WorkItem] wi ON f.[Id] = wi.[FlowId] WHERE wi.[Id] = @WorkItemId
        SELECT TOP(1) @UserFriendlyName = p.[UserFriendlyProjectName] FROM [Project] p INNER JOIN [Flow] f ON p.[Id] = f.[ProjectId] INNER JOIN [WorkItem] wi ON f.[Id] = wi.[FlowId] WHERE wi.[Id] = @WorkItemId
        SELECT TOP(1) @ProjectId = f.[ProjectId] FROM [Flow] f INNER JOIN [WorkItem] wi ON f.[Id] = wi.[FlowId] WHERE wi.[Id] = @WorkItemId

        IF @WorkItemId IS NULL
        BEGIN
            SET @Status = 1
            SET @Message = N'No work items to process'
            ;THROW 51000, @Message, 1
        END

        SET @AvailableMachineId = [dbo].[ufn_GetAvailableMachineId](@Environment)

        IF @AvailableMachineId IS NULL
        BEGIN
            SET @Status = 2
            SET @Message = N'Available work item was found with id ' + CAST(@WorkItemId AS NVARCHAR) + ', but all machines are currently busy'
            ;THROW 51000, @Message, 1
        END

        SET @MachineName = [dbo].[ufn_GetMachineNameById](@AvailableMachineId)
        SELECT TOP(1) @Environments = m.[Environments] FROM [Machine] m WHERE m.[Id] = @AvailableMachineId

        IF @FlowName IS NULL
        BEGIN
            SET @Status = -3
            SET @Message = N'Could not find Flow name for work item id ' + CAST(@WorkItemId AS NVARCHAR)
            ;THROW 51000, @Message, 1
        END
        ELSE IF @ProjectNumber IS NULL
        BEGIN
            SET @Status = -4
            SET @Message = N'Could not find project number for work item id ' + CAST(@WorkItemId AS NVARCHAR)
            ;THROW 51000, @Message, 1
        END

        -- Assign MachineId so it's no longer NULL, so distributor does not pick it up again
        UPDATE [WorkItem]
        SET
            [MachineId] = @AvailableMachineId,
            [UpdatedAtUTC] = @UpdatedAtUTC
        WHERE
            [Id] = @WorkItemId

        SET @Status = 0
        SET @Message = N'Found highest value work item with id ' + CAST(@WorkItemId AS NVARCHAR) + '. Assigned it to machine ' + @MachineName

        COMMIT TRANSACTION

        SELECT @WorkItemId 'WorkItemId', @AvailableMachineId 'AvailableMachineId', @ProjectNumber 'ProjectNumber', @FlowName 'FlowName', @UserFriendlyName 'UserFriendlyProjectName', @MachineName 'MachineName', @Environments 'Environments', @Status 'Status', @Message 'Message'
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
