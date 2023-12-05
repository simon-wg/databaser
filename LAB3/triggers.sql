CREATE FUNCTION on_registration_insert() RETURNS trigger AS
$$
BEGIN
    -- Check if student has already passed the course
    IF EXISTS (SELECT * FROM PassedCourses WHERE student = NEW.student AND course = NEW.course) THEN
        RAISE EXCEPTION 'Student % has already passed course %', NEW.student, NEW.course;
    END IF;
    -- Check if student is qualified for the course
    IF (SELECT COUNT(*) FROM Prerequisites WHERE course = NEW.course) > 0 THEN
        RAISE NOTICE 'Checking if student % is qualified for course %', NEW.student, NEW.course;
        IF (SELECT COUNT(*)
            FROM PassedCourses
                     JOIN Prerequisites ON PassedCourses.course = Prerequisites.prerequisite
            WHERE PassedCourses.student = NEW.student
              AND Prerequisites.course = NEW.course) <
           (SELECT COUNT(*) FROM Prerequisites WHERE course = NEW.course) THEN
            RAISE EXCEPTION 'Student % is not qualified for course %', NEW.student, NEW.course;
        END IF;
    END IF;
    -- Check if student is already registered for the course
    IF EXISTS (SELECT * FROM Registered WHERE student = NEW.student AND course = NEW.course) THEN
        RAISE EXCEPTION 'Student % is already registered for course %', NEW.student, NEW.course;
    END IF;
    IF EXISTS (SELECT * FROM WaitingList WHERE student = NEW.student AND course = NEW.course) THEN
        RAISE EXCEPTION 'Student % is already on the waitinglist for course %', NEW.student, NEW.course;
    END IF;
    IF (SELECT COUNT(*) FROM Registered WHERE course = NEW.course) >=
       (SELECT capacity FROM LimitedCourses WHERE code = NEW.course) THEN
        INSERT INTO WaitingList
        VALUES (NEW.student, NEW.course, (SELECT COUNT(*) FROM WaitingList WHERE course = NEW.course));
    ELSE
        INSERT INTO Registered VALUES (NEW.student, NEW.course);
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION on_registration_delete() RETURNS trigger AS
$$
BEGIN
    IF EXISTS (SELECT * FROM WaitingList WHERE student = OLD.student AND course = OLD.course) THEN
        DELETE FROM WaitingList WHERE student = OLD.student AND course = OLD.course;
    ELSE
        DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
        INSERT INTO Registered
        SELECT student, course
        FROM WaitingList
        WHERE course = OLD.course
        ORDER BY position ASC
        LIMIT 1;
        DELETE FROM WaitingList WHERE course = OLD.course AND position = 0;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION compact_waiting_list() RETURNS trigger AS
$$
BEGIN
    UPDATE WaitingList SET position = position - 1 WHERE course = OLD.course AND position > OLD.position;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_registration_insert
    INSTEAD OF INSERT
    ON Registrations
    FOR ROW
EXECUTE PROCEDURE on_registration_insert();

CREATE TRIGGER on_registration_delete
    INSTEAD OF DELETE
    ON Registrations
    FOR ROW
EXECUTE PROCEDURE on_registration_delete();

CREATE TRIGGER compact_waiting_list
    AFTER DELETE
    ON WaitingList
    FOR EACH ROW
EXECUTE PROCEDURE compact_waiting_list();