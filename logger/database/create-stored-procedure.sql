CREATE PROCEDURE [dbo].[usp_InsertLogMessage]
    @Level NVARCHAR(50),
    @MachineName NVARCHAR(50),
    @Project NVARCHAR(100),
    @Flow NVARCHAR(50),
    @Subflow NVARCHAR(50),
    @Message NVARCHAR(MAX)

AS
BEGIN
    DECLARE @Status SMALLINT
            ,@Message NVARCHAR(MAX)
    BEGIN TRY
        BEGIN TRANSACTION
        SET NOCOUNT ON
        -- on stored procedure fatal, rollbacks transaction so it is not kept alive
        SET XACT_ABORT ON

        DECLARE @Timestamp DATETIMEOFFSET(3) = TODATETIMEOFFSET(GETDATE(), 0)

        -- try to lock stored procedure exclusively, wait for 30s
        EXEC @Result = sp_getapplock @Resource = 'usp_InsertLogMessage', @LockMode = 'Exclusive', @LockTimeout = 30000, @LockOwner = 'Transaction'

        IF @Result < 0
        BEGIN
            SET @Status = -2
            SET @Message = N'Failed to lock stored procedure usp_InsertLogMessage exclusively'
            ;THROW 51000, @Message, 1
        END

        INSERT INTO [LogMessages] (Level, Timestamp, Machine, Project, Flow, Subflow, Message)
        VALUES
        (@Level, @Timestamp, @Machine, @Project, @Flow, @Subflow, @Message)

        SET @Status = 0
        SET @Message = N'Successfully inserted log message for project ' + @Project + ' flow ' + @Flow

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