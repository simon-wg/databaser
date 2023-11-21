-- This script deletes everything in your database
\set QUIET true
SET client_min_messages TO WARNING; -- Less talk please.
-- This script deletes everything in your database
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO CURRENT_USER;
-- This line makes psql stop on the first error it encounters
-- You may want to remove this when running tests that are intended to fail
\set ON_ERROR_STOP ON
SET client_min_messages TO NOTICE; -- More talk
\set QUIET false


-- \ir is for include relative, it will run files in the same directory as this file
-- Note that these are not SQL statements but rather Postgres commands (no terminating semicolon). 
\ir tables.sql
\ir inserts.sql
\ir views.sql



-- Tests various queries from the assignment, uncomment these as you make progress
SELECT idnr, name, login, program, branch 
FROM BasicInformation ORDER BY idnr;

SELECT student, course, courseName, grade, credits FROM FinishedCourses ORDER BY (student, course);

SELECT student, course, status FROM Registrations ORDER BY (status, course, student);


-- Helper views for PathToGraduation (optional)
SELECT student, course, credits FROM PassedCourses ORDER BY (student, course);
SELECT student, course FROM UnreadMandatory ORDER BY (student, course);
--SELECT student, course FROM UnreadMandatory ORDER BY (student, course);
--SELECT student, course, credits FROM RecommendedCourses ORDER BY (student, course);
SELECT student, branch, recommendedCredits FROM RecommendedPassed ORDER BY (student);
SELECT student, totalCredits, mandatoryLeft, mathCredits, seminarCourses, qualified FROM PathToGraduation ORDER BY student;

-- Life-hack: When working on a new view you can write it as a query here (without creating a view) and when it works just add CREATE VIEW and put it in views.sql

SELECT idnr AS student, MandatoryProgram.course FROM Students LEFT JOIN MandatoryProgram ON (Students.program = MandatoryProgram.program) LEFT JOIN PassedCourses ON (idnr = PassedCourses.student) WHERE (PassedCourses.grade IS NULL AND MandatoryProgram.course IS NOT NULL)
UNION
SELECT idnr AS student, MandatoryBranch.course FROM Students LEFT JOIN StudentBranches ON (Students.idnr = StudentBranches.student) LEFT JOIN MandatoryBranch ON (Students.program = MandatoryBranch.program AND StudentBranches.branch = MandatoryBranch.branch) LEFT JOIN PassedCourses ON (idnr = PassedCourses.student) WHERE (PassedCourses.grade IS NULL)
ORDER BY student;
