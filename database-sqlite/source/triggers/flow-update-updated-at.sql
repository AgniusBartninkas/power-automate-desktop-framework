CREATE TRIGGER Flow_Update_UpdatedAt
    AFTER UPDATE ON Flow
BEGIN
    UPDATE Flow
    SET UpdatedAt = (strftime('%Y-%m-%d %H:%M.%f', 'now'))
    WHERE Id = NEW.Id
    AND UpdatedAt != (strftime('%Y-%m-%d %H:%M.%f', 'now'));
END;