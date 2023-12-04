CREATE FUNCTION on_register() RETURNS trigger AS $$
BEGIN
--Checks if studnet is already in registration or watinglist and throws an exception
IF (
  EXISTS (
    SELECT
      *
    FROM
      Registrations
    WHERE
      student = NEW.student
      AND course = NEW.course
  )
) THEN RAISE EXCEPTION 'Student already registered or waiting.';

END IF;

-- CHECK IF STUDENT IS ALLOWED TO REGISTER FOR A COURSE :)
IF (
  EXISTS (
    SELECT
      *
    FROM
      Prerequisites
    WHERE
      Prerequisites.course = NEW.course
  )
) THEN
--Checks if student has passed all the courses that is in prerequisites
IF (
  NOT EXISTS (
    SELECT
      *
    FROM
      Prerequisites
      JOIN PassedCourses ON (required_course = PassedCourses.course)
    WHERE
      (
        Prerequisites.course = NEW.course
        AND student = NEW.student
      )
  )
) THEN RAISE EXCEPTION 'Student has not taken the right courses';

END IF;

END IF;

--If there is 
IF (
  (
    SELECT
      capacity
    FROM
      LimitedCourses
    WHERE
      code = NEW.course
  ) <= (
    SELECT
      COUNT(*)
    FROM
      Registrations
    WHERE
      course = NEW.course
  )
) THEN
INSERT INTO
  WaitingList
VALUES
  (NEW.student, NEW.course, 1);

RETURN OLD;

END IF;

IF NOT (
  (
    SELECT
      COUNT(*)
    FROM
      Prerequisites
      RIGHT JOIN PassedCourses ON (
        Prerequisites.required_course = PassedCourses.course
      )
    WHERE
      Prerequisites.course = NEW.course
      AND student = NEW.student
  ) = (
    SELECT
      COUNT(*)
    FROM
      Prerequisites
    WHERE
      Prerequisites.course = NEW.course
  )
) THEN RAISE EXCEPTION 'Student has not completed the required courses.';

END IF;

RETURN NEW;

END;
$$ LANGUAGE plpgsql;



CREATE FUNCTION on_waitinglist_insert() RETURNS trigger AS $$
DECLARE pos INT;

BEGIN IF (
  EXISTS (
    SELECT
      *
    FROM
      Registrations
    WHERE
      student = NEW.student
      AND course = NEW.course
  )
) THEN RAISE EXCEPTION 'Student already registered or waiting.';

END IF;

IF NOT (
  (
    SELECT
      COUNT(*)
    FROM
      Prerequisites
      RIGHT JOIN PassedCourses ON (
        Prerequisites.required_course = PassedCourses.course
      )
    WHERE
      Prerequisites.course = NEW.course
      AND student = NEW.student
  ) = (
    SELECT
      COUNT(*)
    FROM
      Prerequisites
    WHERE
      Prerequisites.course = NEW.course
  )
) THEN RAISE EXCEPTION 'Student has not completed the required courses.';

END IF;

SELECT
  COUNT(*) + 1 INTO NEW.position
FROM
  WaitingList
WHERE
  course = NEW.course;

RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION compact() RETURNS trigger AS $$
BEGIN
  IF (SELECT COUNT(*) FROM Registered WHERE course = OLD.course) < (SELECT capacity FROM LimitedCourses WHERE code = OLD.course) THEN
    RAISE EXCEPTION 'Course is not full';
    INSERT INTO Registered VALUES (OLD.student, OLD.course);
    DELETE FROM WaitingList WHERE course = OLD.course AND position = (SELECT MIN(position) FROM WaitingList WHERE course = OLD.course);
  END IF;
  UPDATE WaitingList SET position = position - 1 WHERE position > OLD.position AND course = OLD.course;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER on_register BEFORE INSERT ON Registered FOR ROW EXECUTE PROCEDURE on_register ();

CREATe TRIGGER on_register_delete AFTER DELETE ON Registered FOR EACH ROW EXECUTE PROCEDURE compact ();

CREATE TRIGGER on_waitinglist_insert BEFORE INSERT ON WaitingList FOR ROW EXECUTE PROCEDURE on_waitinglist_insert ();

CREATE TRIGGER on_waitinglist_delete AFTER DELETE ON WaitingList FOR EACH ROW EXECUTE PROCEDURE compact ();