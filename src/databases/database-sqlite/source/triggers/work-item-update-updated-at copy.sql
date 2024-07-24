CREATE TRIGGER WorkItem_Update_UpdatedAt
    AFTER UPDATE ON WorkItem
BEGIN
    UPDATE WorkItem
    SET UpdatedAt = (strftime('%Y-%m-%d %H:%M.%f', 'now'))
    WHERE Id = NEW.Id
    AND UpdatedAt != (strftime('%Y-%m-%d %H:%M.%f', 'now'));
END;