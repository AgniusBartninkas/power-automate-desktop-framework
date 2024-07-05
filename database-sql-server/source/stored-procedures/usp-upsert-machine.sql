CREATE PROCEDURE [dbo].[usp_UpsertMachine]
    @MachineName NVARCHAR(MAX),
    @Environments NVARCHAR(255),
    @SupportedProjectNumbers NVARCHAR(MAX)

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
            SET @Message = N'Successfully updated machine with id ' + CAST(@MachineId AS NVARCHAR) + ', data=(Name=' + @MachineName + ';SupportedProjectNumbers=' + CAST(@SupportedProjectNumbers AS NVARCHAR) + ')'
        END
        ELSE
        BEGIN
            INSERT INTO [Machine] (Name, Environments, InsertedAtUTC, UpdatedAtUTC)
            VALUES
            (@MachineName, @Environments, @InsertedAtUTC, @UpdatedAtUTC)
            SET @Status = 0
            SET @Message = N'Successfully inserted new machine with data=(Name=' + @MachineName + ';SupportedProjectNumbers=' + CAST(@SupportedProjectNumbers AS NVARCHAR) + ')'
            -- Calling this to get the MachineId after a new machine was inserted to process the Mapping procedure below.
            SET @MachineId = [dbo].[ufn_GetMachineId](@MachineName)
        END

        -- Adding values to MachineSupportedProject. Not changing status declared above, unless this fails, so as to retain whether an existing machine was updated or a new one was inserted.
        SELECT @Count = COUNT(value) FROM STRING_SPLIT(@SupportedProjectNumbers, ',')

        IF @Count > 0
        BEGIN
            -- Clearing any existing mapping in order to only keep updated entries.
            DELETE FROM [MachineSupportedProject] WHERE MachineId = @MachineId
        

            WHILE @i < @Count
            BEGIN
                -- TRIM() not supported by the version of SQL server OBH uses.
                SELECT @ProjectNumber = RTRIM(LTRIM(value)) FROM STRING_SPLIT(@SupportedProjectNumbers, ',') ORDER BY value ASC OFFSET @i ROWS FETCH NEXT 1 ROWS ONLY
                SET @ProjectId = [dbo].[ufn_GetProjectId](@ProjectNumber)

                -- Increasing the index here, so that this does not get skipped under the CONTINUE statement if ProjectId is NULL
                SET @i = @i + 1

                -- Not returning errors if any single project is not inserted. Checking whether or not anything is inserted after the loop by using MappingCount.
                IF @ProjectId IS NULL
                CONTINUE;

                INSERT INTO [MachineSupportedProject] (MachineId, ProjectId, InsertedAtUTC, UpdatedAtUTC)
                VALUES
                (@MachineId, @ProjectId, @InsertedAtUTC, @UpdatedAtUTC)

                SET @MappingCount = @MappingCount + 1
            END

            IF @MappingCount = 0
            BEGIN
                SET @Status = -3
                SET @Message = N'No valid values provided for MachineSupportedProjects.'
                ;THROW 51000, @Message, 1
            END
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
