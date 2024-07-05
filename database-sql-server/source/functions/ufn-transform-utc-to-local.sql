CREATE FUNCTION [dbo].[ufn_TransformUTCToLocal]
(
    @Date DATETIMEOFFSET(3)
)
RETURNS DATETIMEOFFSET(3)

AS
BEGIN
    DECLARE @Timezone NVARCHAR(MAX)

    SET @Timezone = [dbo].[ufn_GetLocalTimezone]()

    RETURN CONVERT(DATETIMEOFFSET(3), @Date, 126) AT TIME ZONE @Timezone
END
GO