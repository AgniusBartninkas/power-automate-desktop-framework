CREATE PROCEDURE [dbo].[usp_GetConfigValues]
    @ProjectNumber NVARCHAR(MAX)

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
                ,@ProjectId SMALLINT
        -- try to lock stored procedure exclusively, wait for 30s
        EXEC @Result = sp_getapplock @Resource = 'usp_GetConfigValues', @LockMode = 'Exclusive', @LockTimeout = 30000, @LockOwner = 'Transaction'

        IF @Result < 0
        BEGIN
            SET @Status = -2
            SET @Message = N'Failed to lock stored procedure usp_GetConfigValues exclusively'
            ;THROW 51000, @Message, 1
        END

        SET @ProjectId = [dbo].[ufn_GetProjectId](@ProjectNumber)

		IF @ProjectId IS NULL
        BEGIN
            SET @Status = -3
            SET @Message = N'Could not find Project ' + @ProjectNumber + ' in Project table'
            ;THROW 51000, @Message, 1
        END

        COMMIT TRANSACTION
		
		SELECT  
			f.[Name] 'Flow Name'
            ,c.[PropertyName] 'Property Name'
			,c.[Value]
            ,c.[DataType] 'Data Type'
			,@Status 'Status'
			,@Message 'Message'
		FROM 
			[Config] c 
			INNER JOIN [Project] p ON c.[ProjectId] = p.[Id]
            LEFT OUTER JOIN [Flow] f ON c.[FlowId] = f.[Id] 
		WHERE 
        p.[ProjectNumber] = @ProjectNumber

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


