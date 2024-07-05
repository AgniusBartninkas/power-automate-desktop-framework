CREATE PROCEDURE [dbo].[usp_GetConfigValueByPropertyName]
    @ProjectNumber NVARCHAR(MAX),
    @FlowName NVARCHAR(MAX) NULL,
	@PropertyName NVARCHAR(MAX)

AS
BEGIN
    DECLARE @ConfigId SMALLINT
			,@Status SMALLINT
            ,@Message NVARCHAR(MAX)
    BEGIN TRY
        BEGIN TRANSACTION
        SET NOCOUNT ON
        -- on stored procedure fatal, rollbacks transaction so it is not kept alive
        SET XACT_ABORT ON

        DECLARE @Result INT
                ,@ProjectId SMALLINT
        -- try to lock stored procedure exclusively, wait for 30s
        EXEC @Result = sp_getapplock @Resource = 'usp_GetConfigValueByPropertyName', @LockMode = 'Exclusive', @LockTimeout = 30000, @LockOwner = 'Transaction'

        IF @Result < 0
        BEGIN
            SET @Status = -2
            SET @Message = N'Failed to lock stored procedure usp_GetConfigValueByPropertyName exclusively'
            ;THROW 51000, @Message, 1
        END

        SET @ProjectId = [dbo].[ufn_GetProjectId](@ProjectNumber)
		SET @ConfigId = [dbo].[ufn_GetConfigByProjectNumberAndProperty](@ProjectNumber, @FlowName, @PropertyName)

		IF @ProjectId IS NULL
        BEGIN
            SET @Status = -3
            SET @Message = N'Could not find Project ' + @ProjectNumber + ' in Project table'
            ;THROW 51000, @Message, 1
        END

		IF @ConfigId IS NULL
		BEGIN
            SET @Status = -4
            SET @Message = N'Could not find config property with name ' + @PropertyName + ' and project ' + @ProjectNumber + ' in TabularConfig table'
            ;THROW 51000, @Message, 1
        END

        COMMIT TRANSACTION
		
		SELECT  
			Value
			,@Status 'Status'
			,@Message 'Message'
		FROM 
			[Config]  
		WHERE 
			Id = @ConfigId

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
GO


