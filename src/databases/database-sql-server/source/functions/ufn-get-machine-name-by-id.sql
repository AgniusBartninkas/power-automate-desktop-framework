CREATE FUNCTION [dbo].[ufn_GetMachineNameById]
(
    @Id SMALLINT
)
RETURNS NVARCHAR(MAX)

AS
BEGIN
    DECLARE @Name NVARCHAR(MAX)

    SELECT TOP(1) @Name = m.[Name] FROM [Machine] m WHERE m.[Id] = @Id

    RETURN @Name
END
GO