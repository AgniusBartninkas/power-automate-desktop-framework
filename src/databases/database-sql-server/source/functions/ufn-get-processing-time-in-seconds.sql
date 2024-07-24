CREATE FUNCTION [dbo].[ufn_GetProcessingTimeInSeconds]
(
    @ProcessingStartUTC DATETIMEOFFSET(3),
    @ProcessingEndUTC DATETIMEOFFSET(3)
)
RETURNS INTEGER

AS
BEGIN
    DECLARE @Seconds INTEGER

    SELECT @Seconds = DATEDIFF(SECOND, @ProcessingStartUTC, @ProcessingEndUTC)

    RETURN @Seconds
END
GO