CREATE PROCEDURE [dbo].[usp_UpsertProject]

    @ProjectNumber NVARCHAR(50),
    @UserFriendlyProjectName NVARCHAR(MAX)

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
                ,@Result INT
                ,@InsertedAtUTC DATETIMEOFFSET(3)
                ,@UpdatedAtUTC DATETIMEOFFSET(3)
        -- try to lock stored procedure exclusively, wait for 30s
        EXEC @Result = sp_getapplock @Resource = 'usp_UpsertProject', @LockMode = 'Exclusive', @LockTimeout = 30000, @LockOwner = 'Transaction'

        IF @Result < 0
        BEGIN
            SET @Status = -2
            SET @Message = N'Failed to lock stored procedure usp_UpsertProject exclusively'
            ;THROW 51000, @Message, 1
        END

        SET @InsertedAtUTC = [dbo].[ufn_GetUTCDate]()
        SET @UpdatedAtUTC = @InsertedAtUTC
        SET @ProjectId = [dbo].[ufn_GetProjectId](@ProjectNumber)

        IF @ProjectId IS NOT NULL
        BEGIN
            UPDATE Project
            SET ProjectNumber = @ProjectNumber,
                UserFriendlyProjectName = @UserFriendlyProjectName
            WHERE Id = @ProjectId

            SET @Status = 1
            SET @Message = N'Project with project number ' + @ProjectNumber + ' already exists in Project table, updated it with provided values=(ProjectNumber=' + @ProjectNumber + ';UserFriendlyProjectName=' + @UserFriendlyProjectName + ')'
        END
        ELSE
        BEGIN
            INSERT INTO [Project] (ProjectNumber, UserFriendlyProjectName, InsertedAtUTC, UpdatedAtUTC)
            VALUES
            (@ProjectNumber, @UserFriendlyProjectName, @InsertedAtUTC, @UpdatedAtUTC)

            SET @Status = 0
            SET @Message = N'Successfully inserted project with data (ProjectNumber=' + @ProjectNumber + ';UserFriendlyProjectName=' + @UserFriendlyProjectName + ';Date=' + CAST(@InsertedAtUTC AS NVARCHAR) + ')'
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