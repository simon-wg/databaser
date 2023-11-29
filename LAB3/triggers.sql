CREATE FUNCTION on_register() RETURNS trigger AS $$
BEGIN
  IF (EXISTS (SELECT * FROM Registrations WHERE student = NEW.student AND course = NEW.course)) THEN
    RAISE EXCEPTION 'Student already registered or waiting.';
  END IF;
  -- CHECK IF STUDENT IS ALLOWED TO REGISTER FOR A COURSE :)
  IF (NOT EXISTS (SELECT * FROM Prerequisites JOIN Taken ON (required_course = Taken.course) WHERE (Prerequisites.course = NEW.course  AND student = NEW.student))) THEN
    RAISE EXCEPTION 'Student has not taken the right courses';
  END IF;
  IF ((SELECT capacity FROM LimitedCourses WHERE code = NEW.course) <= (SELECT COUNT(*) FROM Registrations WHERE course = NEW.course)) THEN
    INSERT INTO WaitingList VALUES(NEW.student, NEW.course, 1);
    RETURN OLD;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION on_waitinglist_insert() RETURNS trigger AS $$
DECLARE
  pos INT;
BEGIN
  IF (EXISTS (SELECT * FROM Registrations WHERE student = NEW.student AND course = NEW.course)) THEN
    RAISE EXCEPTION 'Student already registered or waiting.';
  END IF;
  IF (NOT EXISTS (SELECT * FROM Prerequisites JOIN Taken ON (required_course = Taken.course) WHERE (Prerequisites.course = NEW.course  AND student = NEW.student))) THEN
    RAISE EXCEPTION 'Student has not taken the right courses';
  END IF;
  SELECT COUNT(*)+1 INTO NEW.position FROM WaitingList WHERE course = NEW.course;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_register BEFORE INSERT ON Registered
    FOR ROW EXECUTE PROCEDURE on_register();

CREATE TRIGGER on_waitinglist_insert BEFORE INSERT ON WaitingList
    FOR ROW EXECUTE PROCEDURE on_waitinglist_insert();