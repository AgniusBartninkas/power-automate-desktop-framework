CREATE PROCEDURE [dbo].[usp_UpdateFlowId]
    @WorkItemId BIGINT,
    @NextFlowName NVARCHAR(MAX),
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
                ,@FlowId SMALLINT
				,@ProjectId SMALLINT
                ,@InsertedAtUTC DATETIMEOFFSET(3)
                ,@UpdatedAtUTC DATETIMEOFFSET(3)
        -- try to lock stored procedure exclusively, wait for 30s
        EXEC @Result = sp_getapplock @Resource = 'usp_UpdateFlowId', @LockMode = 'Exclusive', @LockTimeout = 30000, @LockOwner = 'Transaction'

        IF @Result < 0
        BEGIN
            SET @Status = -2
            SET @Message = N'Failed to lock stored procedure usp_UpdateFlowId exclusively'
            ;THROW 51000, @Message, 1
        END

        SET @InsertedAtUTC = [dbo].[ufn_GetUTCDate]()
        SET @UpdatedAtUTC = @InsertedAtUTC

		SET @ProjectId = [dbo].[ufn_GetProjectId](@ProjectNumber)

		IF @ProjectId IS NULL
        BEGIN
            SET @Status = -3
            SET @Message = N'Project with project number ' + @ProjectNumber + ' does not exist in Project table'
            ;THROW 51000, @Message, 1
        END

        SET @FlowId = [dbo].[ufn_GetFlowId](@NextFlowName, @ProjectId)

        IF @FlowId IS NULL
        BEGIN
            SET @Status = -4
            SET @Message = N'Failed to find Flow id for Flow name ' + @NextFlowName + ' under Project number ' + @ProjectNumber

            ;THROW 51000, @Message, 1
        END

        UPDATE [WorkItem]
        SET
            [FlowId] = @FlowId,
            [RetrieveCount] = 0,
            [MachineId] = NULL,
            [UpdatedAtUTC] = @UpdatedAtUTC
        WHERE
            [Id] = @WorkItemId

        SET @Status = 0
        SET @Message = N'Successfully updated work item with id ' + CAST(@WorkItemId AS NVARCHAR) + ' and changed it for next Flow ' + @NextFlowName

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