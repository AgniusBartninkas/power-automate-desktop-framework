CREATE FUNCTION [dbo].[ufn_GetMachineId]
(
    @MachineName NVARCHAR(MAX)
)
RETURNS SMALLINT

AS
BEGIN
    DECLARE @MachineId SMALLINT

    SELECT TOP(1) @MachineId = m.[Id] FROM [Machine] m WHERE m.[Name] = @MachineName

    RETURN @MachineId
END
GO