CREATE FUNCTION [dbo].[ufn_GetLocalTimezone]()
RETURNS NVARCHAR(255)

AS
BEGIN
    DECLARE @Timezone NVARCHAR(255)

    EXEC MASTER.dbo.xp_regread 'HKEY_LOCAL_MACHINE',
    'SYSTEM\CurrentControlSet\Control\TimeZoneInformation',
    'TimeZoneKeyName', @Timezone OUT

    RETURN @Timezone
END
GO