CREATE PROCEDURE [dbo].[usp_UpsertCredential]
    @Name NVARCHAR(MAX),
    @Username NVARCHAR(MAX) = NULL,
    @Password NVARCHAR(MAX),
    @ReadOnly BIT = NULL

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
                ,@CredentialId INT
                ,@ReadOnlyBit BIT
                ,@HashedPassword NVARCHAR(MAX)
                ,@InsertedAtUTC DATETIMEOFFSET(3)
                ,@UpdatedAtUTC DATETIMEOFFSET(3)
        -- try to lock stored procedure exclusively, wait for 30s
        EXEC @Result = sp_getapplock @Resource = 'usp_UpsertCredential', @LockMode = 'Exclusive', @LockTimeout = 30000, @LockOwner = 'Transaction'

        IF @Result < 0
        BEGIN
            SET @Status = -2
            SET @Message = N'Failed to lock stored procedure usp_UpsertCredential exclusively'
            ;THROW 51000, @Message, 1
        END

        SET @InsertedAtUTC = [dbo].[ufn_GetUTCDate]()
        SET @UpdatedAtUTC = @InsertedAtUTC

        OPEN SYMMETRIC KEY CredentialProtector
        DECRYPTION BY CERTIFICATE CredentialProtectorCertificate
        SET @HashedPassword = EncryptByKey(KEY_GUID('CredentialProtector'), @Password)

        SELECT TOP(1) @CredentialId = c.[Id] FROM [Credential] c WHERE c.[Name] = @Name
        IF @CredentialId IS NOT NULL
        BEGIN
            SELECT @ReadOnlyBit = c.[ReadOnly] FROM [Credential] c WHERE c.[Id] = @CredentialId
            IF @ReadOnlyBit = 1
            BEGIN
                SET @Status = -3
                SET @Message = N'Credential with name ' + @Name + ' is read-only. Will not update this credential.'
                ;THROW 51000, @Message, 1
            END
            ELSE
            BEGIN
                IF @Username IS NOT NULL
                BEGIN
                    UPDATE [Credential]
                    SET [Name] = @Name,
                        [Username] = @Username,
                        [HashedPassword] = @HashedPassword,
                        [UpdatedAtUTC] = @UpdatedAtUTC
                    WHERE
                        [Id] = @CredentialId

                    SET @Status = 1
                    SET @Message = N'Successfully updated credential with name ' + @Name + ' and username ' + @Username
                END
                ELSE
                BEGIN
                    UPDATE [Credential]
                        SET [HashedPassword] = @HashedPassword,
                            [UpdatedAtUTC] = @UpdatedAtUTC
                    WHERE [Id] = @CredentialId
                    SET @Status = 2
                    SET @Message = N'Successfully updated credential password with name ' + @Name
                END
            END
        END
        ELSE
        BEGIN
            IF @Username IS NULL
            BEGIN
                SET @Status = -4
                SET @Message = N'Credential with provided values does not exist, however, username was not provided to insert a new one'
                ;THROW 51000, @Message, 1
            END
            ELSE IF @ReadOnly IS NULL
            BEGIN
                SET @Status = -5
                SET @Message = N'Credential with provided values does not exist, however, read-only bit not provided'
                ;THROW 51000, @Message, 1
            END
            INSERT INTO [Credential] (Name, Username, HashedPassword, ReadOnly, InsertedAtUTC, UpdatedAtUTC)
            VALUES
            (@Name, @Username, @HashedPassword, @ReadOnly, @InsertedAtUTC, @UpdatedAtUTC)
            SET @Status = 0
            SET @Message = N'Successfully inserted new credential with name ' + @Name + ' and username ' + @Username
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