CREATE TRIGGER WorkItemData_Update_UpdatedAt
    AFTER UPDATE ON WorkItemData
BEGIN
    UPDATE WorkItemData
    SET UpdatedAt = (strftime('%Y-%m-%d %H:%M.%f', 'now'))
    WHERE Id = NEW.Id
    AND UpdatedAt != (strftime('%Y-%m-%d %H:%M.%f', 'now'));
END;