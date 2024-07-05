CREATE PROCEDURE [dbo].[usp_UpsertFlow]
    @ProjectNumber NVARCHAR(50),
    @FlowName NVARCHAR(MAX)

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
                ,@InsertedAtUTC DATETIMEOFFSET(3)
                ,@UpdatedAtUTC DATETIMEOFFSET(3)
                ,@ProjectId INT
                ,@FlowId INT
        -- try to lock stored procedure exclusively, wait for 30s
        EXEC @Result = sp_getapplock @Resource = 'usp_UpsertFlow', @LockMode = 'Exclusive', @LockTimeout = 30000, @LockOwner = 'Transaction'

        IF @Result < 0
        BEGIN
            SET @Status = -2
            SET @Message = N'Failed to lock stored procedure usp_UpsertFlow exclusively'
            ;THROW 51000, @Message, 1
        END

        SET @ProjectId = [dbo].[ufn_GetProjectId](@ProjectNumber)

		IF @ProjectId IS NULL
        BEGIN
            SET @Status = -3
            SET @Message = N'Project with project number ' + @ProjectNumber + ' does not exist in Project table'
            ;THROW 51000, @Message, 1
        END

        SET @FlowId = [dbo].[ufn_GetFlowId](@FlowName, @ProjectId)
        SET @InsertedAtUTC = [dbo].[ufn_GetUTCDate]()
        SET @UpdatedAtUTC = @InsertedAtUTC


        IF @FlowId IS NOT NULL
        BEGIN
            UPDATE [Flow]
            SET [ProjectId] = @ProjectId,
                [Name] = @FlowName,
                [UpdatedAtUTC] = @UpdatedAtUTC
            WHERE
                Id = @FlowId
            SET @Status = 1
            SET @Message = N'Successfully updated Flow with id ' + CAST(@FlowId AS NVARCHAR) + ', data=(FlowName=' + @FlowName + ';ProjectId=' + CAST(@ProjectId AS NVARCHAR) + ')'
        END
        ELSE
        BEGIN
            INSERT INTO [Flow] (Name, ProjectId, InsertedAtUTC, UpdatedAtUTC)
            VALUES
            (@FlowName, @ProjectId, @InsertedAtUTC, @UpdatedAtUTC)
            SET @Status = 0
            SET @Message = N'Successfully inserted new Flow data=(FlowName=' + @FlowName + ';ProjectId=' + CAST(@ProjectId AS NVARCHAR) + ')'
        END

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