CREATE PROCEDURE [dbo].[usp_UpsertWorkItem]
    @Number NVARCHAR(MAX),
	@ProjectNumber NVARCHAR(50),
    @FlowName NVARCHAR(MAX),
    @DataContent NVARCHAR(MAX),
    @DataSource NVARCHAR(MAX),
    @Priority NVARCHAR(MAX)

AS
BEGIN
    DECLARE @Status SMALLINT
            ,@Message NVARCHAR(MAX)
            ,@WorkItemId BIGINT
            SET @WorkItemId = -1
    BEGIN TRY
        BEGIN TRANSACTION
        SET NOCOUNT ON
        -- on stored procedure fatal, rollbacks transaction so it is not kept alive
        SET XACT_ABORT ON

        DECLARE @Result INT
                ,@FlowId SMALLINT
				,@ProjectId SMALLINT
                ,@StatusId SMALLINT
                ,@PriorityId SMALLINT
                ,@InsertedAtUTC DATETIMEOFFSET(3)
                ,@UpdatedAtUTC DATETIMEOFFSET(3)
        -- try to lock stored procedure exclusively, wait for 30s
        EXEC @Result = sp_getapplock @Resource = 'usp_UpsertWorkItem', @LockMode = 'Exclusive', @LockTimeout = 30000, @LockOwner = 'Transaction'

        IF @Result < 0
        BEGIN
            SET @Status = -2
            SET @Message = N'Failed to lock stored procedure usp_UpsertWorkItem exclusively'
            ;THROW 51000, @Message, 1
        END

        SET @InsertedAtUTC = [dbo].[ufn_GetUTCDate]()
        SET @UpdatedAtUTC = @InsertedAtUTC
        SELECT TOP(1) @WorkItemId = wi.[Id] FROM [WorkItem] wi WHERE wi.[Number] = @Number AND wi.[Processed] = 0
		SET @ProjectId = [dbo].[ufn_GetProjectId] (@ProjectNumber)

		IF @ProjectId IS NULL
        BEGIN
            SET @Status = -3
            SET @Message = N'Project with number ' + @ProjectNumber + ' does not exist in Project table'
            ;THROW 51000, @Message, 1
        END


        SET @FlowId = [dbo].[ufn_GetFlowId](@FlowName, @ProjectId)
        SET @StatusId = [dbo].[ufn_GetStatusId]('ToDo')
        SET @PriorityId = [dbo].[ufn_GetPriorityId](@Priority)

        IF @FlowId IS NULL
        BEGIN
            SET @Status = -4
            SET @Message = N'Flow with name ' + @FlowName + ' does not exist in Flow table'
            ;THROW 51000, @Message, 1
        END
        ELSE IF @StatusId IS NULL
        BEGIN
            SET @Status = -5
            SET @Message = N'Status with name ToDo not found in Status table'
            ;THROW 51000, @Message, 1
        END
        ELSE IF @PriorityId IS NULL
        BEGIN
            SET @Status = -6
            SET @Message = N'Priority with name ' + @Priority + ' not found in Priority table'
            ;THROW 51000, @Message, 1
        END

        IF @WorkItemId != -1
        BEGIN
            UPDATE WorkItem
            SET Number = @Number,
                RetrieveCount = 0,
                MachineId = NULL,
                FlowId = @FlowId,
                PriorityId = @PriorityId,
                UpdatedAtUTC = @UpdatedAtUTC
            WHERE
                Id = @WorkItemId

            UPDATE WorkItemData
            SET DataContent = @DataContent,
                DataSource = @DataSource,
                UpdatedAtUTC = @UpdatedAtUTC
            WHERE
                WorkItemId = @WorkItemId
            SET @Status = 1
            SET @Message = N'Successfully updated work item with id ' + CAST(@WorkItemId AS NVARCHAR)
        END
        ELSE
        BEGIN
            INSERT INTO WorkItem (Number, StatusId, FlowId, MachineId, PriorityId, RetrieveCount, Processed, IsValueGainedCalculated, InsertedAtUTC, UpdatedAtUTC)
            VALUES
            (@Number, @StatusId, @FlowId, NULL, @PriorityId, 0, 0, 0, @InsertedAtUTC, @UpdatedAtUTC)

            SET @WorkItemId = SCOPE_IDENTITY()

            INSERT INTO WorkItemData (WorkItemId, DataContent, DataSource, InsertedAtUTC, UpdatedAtUTC)
            VALUES (@WorkItemId, @DataContent, @DataSource, @InsertedAtUTC, @UpdatedAtUTC)

            SET @Status = 0
            SET @Message = N'Successfully created new work item with id ' + CAST(@WorkItemId AS NVARCHAR)
        END

        COMMIT TRANSACTION

        SELECT @Status 'Status', @Message 'Message', @WorkItemId 'WorkItemId'
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

        SELECT @Status 'Status', ERROR_MESSAGE() 'Message', @WorkItemId 'WorkItemId'
    END CATCH
END