CREATE PROCEDURE [dbo].[usp_GetAllCredentialNames]


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
        -- try to lock stored procedure exclusively, wait for 30s
        EXEC @Result = sp_getapplock @Resource = 'usp_GetAllCredentialNames', @LockMode = 'Shared', @LockTimeout = 30000, @LockOwner = 'Transaction'

        IF @Result < 0
        BEGIN
            SET @Status = -2
            SET @Message = N'Failed to lock stored procedure usp_GetAllCredentialNames exclusively'
            ;THROW 51000, @Message, 1
        END

        SET @Status = 0
        SET @Message = N'Successfully retrieved all of the credential names'

        COMMIT TRANSACTION

        SELECT c.[Name] 'Name', @Status 'Status', @Message 'Message' FROM [Credential] c
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