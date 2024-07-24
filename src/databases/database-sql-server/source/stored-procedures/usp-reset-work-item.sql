CREATE PROCEDURE [dbo].[usp_ResetWorkItem]
    @WorkItemId BIGINT,
    @FlowName NVARCHAR(MAX),
	@ProjectNumber NVARCHAR(50)

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
                ,@StatusId SMALLINT
				,@ProjectId SMALLINT
                ,@FlowId SMALLINT
                ,@InsertedAtUTC DATETIMEOFFSET(3)
                ,@UpdatedAtUTC DATETIMEOFFSET(3)
        -- try to lock stored procedure exclusively, wait for 30s
        EXEC @Result = sp_getapplock @Resource = 'usp_ResetWorkItem', @LockMode = 'Exclusive', @LockTimeout = 30000, @LockOwner = 'Transaction'

        IF @Result < 0
        BEGIN
            SET @Status = -2
            SET @Message = N'Failed to lock stored procedure usp_ResetWorkItem exclusively'
            ;THROW 51000, @Message, 1
        END

        SET @InsertedAtUTC = [dbo].[ufn_GetUTCDate]()
        SET @UpdatedAtUTC = @InsertedAtUTC
        SET @StatusId = [dbo].[ufn_GetStatusId]('ToDo')

		SET @ProjectId = [dbo].[ufn_GetProjectId](@ProjectNumber)

		IF @ProjectId IS NULL
        BEGIN
            SET @Status = -3
            SET @Message = N'Project with project number ' + @ProjectNumber + ' does not exist in Project table'
            ;THROW 51000, @Message, 1
        END


        SET @FlowId = [dbo].[ufn_GetFlowId](@FlowName, @ProjectId)

        IF NOT EXISTS (SELECT TOP(1) wi.[Id] FROM [WorkItem] wi WHERE wi.[Id] = @WorkItemId)
        BEGIN
            SET @Status = -4
            SET @Message = N'Work item with id ' + CAST(@WorkItemId AS NVARCHAR) + ' does not exist in WorkItem table'
            ;THROW 51000, @Message, 1
        END
        ELSE IF @StatusId IS NULL
        BEGIN
            SET @Status = -5
            SET @Message = N'Could not find status ToDo in Status table'
            ;THROW 51000, @Message, 1
        END
        ELSE IF @FlowId IS NULL
        BEGIN
            SET @Status = -6
            SET @Message = N'Could not find Flow ' + @FlowName + ' in Flow table'
            ;THROW 51000, @Message, 1
        END

        UPDATE [WorkItem]
        SET
            [StatusId] = @StatusId,
            [MachineId] = NULL,
            [FlowId] = @FlowId,
            [RetrieveCount] = 0,
            [ValueGained] = NULL,
            [Processed] = 0,
            [IsValueGainedCalculated] = 0,
            [UpdatedAtUTC] = @UpdatedAtUTC
        WHERE
            [Id] = @WorkItemId

        SET @Status = 0
        SET @Message = N'Successfully reset work item id ' + CAST(@WorkItemId AS NVARCHAR)

        COMMIT TRANSACTION

        SELECT @Status 'Status', @Message 'Message'
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