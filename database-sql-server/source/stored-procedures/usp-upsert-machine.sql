CREATE PROCEDURE [dbo].[usp_UpsertMachine]
    @MachineName NVARCHAR(MAX),
    @Environments NVARCHAR(255)

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
                ,@MachineId INT
                ,@ProjectId INT
                ,@InsertedAtUTC DATETIMEOFFSET(3)
                ,@UpdatedAtUTC DATETIMEOFFSET(3)
                ,@i INT = 0
                ,@Count INT = 0
                ,@String NVARCHAR(MAX)
                ,@ProjectNumber NVARCHAR(MAX)
                ,@MappingId INT
                ,@MappingCount INT = 0

        -- try to lock stored procedure exclusively, wait for 30s
        EXEC @Result = sp_getapplock @Resource = 'usp_UpsertMachine', @LockMode = 'Exclusive', @LockTimeout = 30000, @LockOwner = 'Transaction'

        IF @Result < 0
        BEGIN
            SET @Status = -2
            SET @Message = N'Failed to lock stored procedure usp_UpsertMachine exclusively'
            ;THROW 51000, @Message, 1
        END

        SET @InsertedAtUTC = [dbo].[ufn_GetUTCDate]()
        SET @UpdatedAtUTC = @InsertedAtUTC
        SET @MachineId = [dbo].[ufn_GetMachineId](@MachineName)

        IF @MachineId IS NOT NULL
        BEGIN
            UPDATE [Machine]
            SET [Name] = @MachineName,
                [Environments] = @Environments,
                [UpdatedAtUTC] = @UpdatedAtUTC
            WHERE
                [Id] = @MachineId

            SET @Status = 1
            SET @Message = N'Successfully updated machine with id ' + CAST(@MachineId AS NVARCHAR) + ', data=(Name=' + @MachineName + ';Environments=' + CAST(@Environments AS NVARCHAR) + ')'
        END
        ELSE
        BEGIN
            INSERT INTO [Machine] (Name, Environments, InsertedAtUTC, UpdatedAtUTC)
            VALUES
            (@MachineName, @Environments, @InsertedAtUTC, @UpdatedAtUTC)
            SET @Status = 0
            SET @Message = N'Successfully inserted new machine with data=(Name=' + @MachineName + ';Environments=' + CAST(@Environments AS NVARCHAR) + ')'
            -- Calling this to get the MachineId after a new machine was inserted to process the Mapping procedure below.
            SET @MachineId = [dbo].[ufn_GetMachineId](@MachineName)
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
