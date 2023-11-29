CREATE FUNCTION on_register() RETURNS trigger AS $$
DECLARE
  pos INT;
BEGIN
  SELECT COUNT(*) INTO pos FROM WaitingList WHERE course = NEW.course;
  IF (EXISTS (SELECT * FROM Registrations WHERE student = NEW.student AND course = NEW.course)) THEN
    RAISE EXCEPTION 'Student already registered or waiting.';
  END IF;
  IF ((SELECT capacity FROM LimitedCourses WHERE code = NEW.course) <= (SELECT COUNT(*) FROM Registrations WHERE course = NEW.course)) THEN
    INSERT INTO WaitingList VALUES(NEW.student, NEW.course, pos);
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_register BEFORE INSERT OR UPDATE ON Registered
    FOR EACH ROW EXECUTE PROCEDURE on_register();
