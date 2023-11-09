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

--SELECT student, totalCredits, mandatoryLeft, mathCredits, seminarCourses, qualified FROM PathToGraduation ORDER BY student;

-- Helper views for PathToGraduation (optional)
SELECT student, course, credits FROM PassedCourses ORDER BY (student, course);
SELECT student, course FROM UnreadMandatory ORDER BY (student, course);
--SELECT student, course FROM UnreadMandatory ORDER BY (student, course);
--SELECT student, course, credits FROM RecommendedCourses ORDER BY (student, course);
SELECT student, recommendedCredits FROM RecommendedPassed ORDER BY (student);


-- Life-hack: When working on a new view you can write it as a query here (without creating a view) and when it works just add CREATE VIEW and put it in views.sql
WITH 
TotalCredits AS 
  (SELECT student, 
    SUM(credits) AS credits 
  FROM PassedCourses 
  GROUP BY student),
MandatoryLeft AS 
  (SELECT student, 
    COUNT(course) AS mandatoryLeft 
  FROM UnreadMandatory 
  GROUP BY student),
MathCredits AS 
  (SELECT student,
    SUM(credits) AS mathCredits
  FROM PassedCourses JOIN Classified USING (course)
  WHERE classification = 'math'
  GROUP BY student),
SeminarCourses AS 
  (SELECT student,
    COUNT(course) as seminarCourses
  FROM PassedCourses JOIN Classified USING (course)
  WHERE classification = 'seminar'
  GROUP BY student),
Qualified AS 
  (SELECT student,
    (0 = 0) AS qualified
  FROM MandatoryLeft)

SELECT 
  idnr AS student, 
  COALESCE(credits, 0) AS credits, 
  COALESCE(mandatoryLeft, 0) AS mandatoryLeft,
  COALESCE(mathCredits, 0) AS mathCredits,
  COALESCE(seminarCourses, 0) AS seminarCourses,
  qualified
FROM Students 
LEFT JOIN TotalCredits ON (idnr = TotalCredits.student) 
LEFT JOIN MandatoryLeft ON (idnr = MandatoryLeft.student) 
LEFT JOIN MathCredits ON (idnr = MathCredits.student)
LEFT JOIN SeminarCourses ON (idnr = SeminarCourses.student)
LEFT JOIN RecommendedPassed ON (idnr = RecommendedPassed.student)
FULL OUTER JOIN Qualified ON (idnr = Qualified.student)
GROUP BY idnr, credits, mandatoryLeft, mathCredits, seminarCourses, recommendedCredits, qualified
ORDER BY student;
