CREATE TRIGGER Project_Update_UpdatedAt
    AFTER UPDATE ON Project
BEGIN
    UPDATE Project
    SET UpdatedAt = (strftime('%Y-%m-%d %H:%M.%f', 'now'))
    WHERE Id = NEW.Id
    AND UpdatedAt != (strftime('%Y-%m-%d %H:%M.%f', 'now'));
END;