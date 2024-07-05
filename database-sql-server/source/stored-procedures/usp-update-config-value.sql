CREATE PROCEDURE [dbo].[usp_UpdateConfigValue]

    @ProjectNumber NVARCHAR(MAX),
    @FlowName NVARCHAR(MAX),
    @PropertyName NVARCHAR(MAX),
    @Value NVARCHAR(MAX)

AS
BEGIN
    DECLARE @Status SMALLINT
            ,@Message NVARCHAR(MAX)
    BEGIN TRY
        BEGIN TRANSACTION
        SET NOCOUNT ON
        -- on stored procedure fatal, rollbacks transaction so it is not kept alive
        SET XACT_ABORT ON

        DECLARE @ProjectId INT
                ,@FlowId INT
                ,@ConfigId INT
                ,@Result INT
                ,@InsertedAtUTC DATETIMEOFFSET(3)
                ,@UpdatedAtUTC DATETIMEOFFSET(3)
        -- try to lock stored procedure exclusively, wait for 30s
        EXEC @Result = sp_getapplock @Resource = 'usp_UpdateConfigValue', @LockMode = 'Exclusive', @LockTimeout = 30000, @LockOwner = 'Transaction'

        IF @Result < 0
        BEGIN
            SET @Status = -2
            SET @Message = N'Failed to lock stored procedure usp_UpdateTConfigValue exclusively'
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

        SET @FlowId = [dbo].[ufn_GetFlowId](@FlowName, @ProjectId)

        IF @FlowId IS NULL
        BEGIN
            SET @Status = -4
            SET @Message = N'Flow with name ' + @Flowname + ' does not exist in Flow table'
            ;THROW 51000, @Message, 1
        END

        SET @ConfigId = [dbo].[ufn_GetConfigByProjectNumberAndProperty](@ProjectNumber, @FlowName, @PropertyName)

        IF @ConfigId IS NULL
        BEGIN
            SET @Status = -5
            SET @Message = N'Property with name ' + @PropertyName + ' and project number ' + @ProjectNumber + ' does not exist in Config table'
            ;THROW 51000, @Message, 1
        END

        BEGIN
            UPDATE Config
            SET 
                [Value] = @Value,
                [UpdatedAtUTC] = @UpdatedAtUTC
            WHERE
                Id = @ConfigId
            SET @Status = 1
            SET @Message = N'Config value with project number ' + @ProjectNumber + ' and property name ' + @PropertyName + ' already exists in Config table, updated it with provided values=(Value=' + @Value + ')'
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