CREATE FUNCTION [dbo].[ufn_GetAvailableMachineId]
(
    @Environment NVARCHAR(255)
)
RETURNS SMALLINT

AS
BEGIN
    DECLARE @MachineId SMALLINT

    SELECT TOP(1) @MachineId = m.[Id] 
    FROM 
        [Machine] m 
        LEFT OUTER JOIN 
            (
                SELECT COUNT([Id]) [ItemCount], [MachineId] 
                FROM [WorkItem] 
                GROUP BY [MachineId]
            ) wi ON m.[Id] = wi.[MachineId] 
    WHERE 
        m.[Environments] LIKE CONCAT('%', @Environment, '%')

    RETURN @MachineId
END
GO