CREATE PROCEDURE [dbo].[usp_GetCredentialByName]
    @Name NVARCHAR(MAX)

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
                ,@Username NVARCHAR(MAX)
                ,@Password NVARCHAR(MAX)
                ,@Key NVARCHAR(MAX)
                ,@HashedPassword NVARCHAR(MAX)
        -- try to lock stored procedure exclusively, wait for 30s
        EXEC @Result = sp_getapplock @Resource = 'usp_GetCredentialByName', @LockMode = 'Shared', @LockTimeout = 30000, @LockOwner = 'Transaction'

        IF @Result < 0
        BEGIN
            SET @Status = -2
            SET @Message = N'Failed to lock stored procedure usp_GetCredentialByName exclusively'
            ;THROW 51000, @Message, 1
        END

        IF NOT EXISTS (SELECT TOP(1) Id FROM Credential WHERE Name = @Name)
        BEGIN
            SET @Status = -3
            SET @Message = N'Credential with name ' + @Name + ' does not exist in Credential table'
            ;THROW 51000, @Message, 1
        END

        OPEN SYMMETRIC KEY CredentialProtector
        DECRYPTION BY CERTIFICATE CredentialProtectorCertificate

        SELECT TOP(1) @Username = c.[Username] FROM Credential c WHERE c.Name = @Name
        SELECT TOP(1) @HashedPassword = c.[HashedPassword] FROM Credential c WHERE c.Name = @Name
        SET @Password = DecryptByKey(@HashedPassword)

        SET @Status = 0
        SET @Message = N'Successfully found credential ' + @Name + ' and decrypted password'

        COMMIT TRANSACTION

        SELECT @Name 'Name', @Username 'Username', @Password 'Password', @Status 'Status', @Message 'Message'
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