CREATE VIEW BasicInformation AS
  SELECT idnr, name, login, Students.program, branch 
  FROM Students LEFT JOIN StudentBranches ON (idnr = student);

CREATE VIEW FinishedCourses AS
  SELECT student, course, Courses.name AS courseName, grade, credits
  FROM Students INNER JOIN Taken ON (Students.idnr = Taken.student) JOIN Courses ON (Courses.code = Taken.course);

CREATE VIEW Registrations AS
  SELECT student, course, 'registered' AS status FROM Registered
  UNION
  SELECT student, course, 'waiting' AS status FROM WaitingList;

CREATE VIEW PassedCourses AS
SELECT student, course, credits, grade
FROM FinishedCourses 
WHERE grade='3' OR grade='4' OR grade='5';

CREATE VIEW RecommendedPassed AS
SELECT student, StudentBranches.branch AS branch, SUM(credits) AS recommendedCredits
FROM PassedCourses 
LEFT JOIN StudentBranches USING (student)
JOIN RecommendedBranch USING (course)
WHERE StudentBranches.branch = RecommendedBranch.branch AND StudentBranches.program = RecommendedBranch.program
GROUP BY student, StudentBranches.branch;

CREATE VIEW UnreadMandatory AS 
  SELECT idnr AS student, COALESCE(MandatoryProgram.course, PassedCourses.course) AS course FROM Students JOIN MandatoryProgram USING (program) LEFT JOIN PassedCourses ON (idnr=PassedCourses.student AND MandatoryProgram.course=PassedCourses.course) WHERE PassedCourses.grade IS NULL
  UNION
  SELECT StudentBranches.student, course FROM StudentBranches JOIN MandatoryBranch USING (program)
  LEFT JOIN PassedCourses USING (student, course) WHERE PassedCourses.grade IS NULL AND MandatoryBranch.program = StudentBranches.program;

CREATE VIEW PathToGraduation AS
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
  (SELECT idnr AS student,
    (COALESCE(mandatoryLeft, 0) = 0 
    AND COALESCE(recommendedCredits, 0) >= 10
    AND COALESCE(mathCredits, 0) >= 20
    AND COALESCE(seminarCourses, 0) >= 1)
    AS qualified
  FROM Students 
  LEFT JOIN MandatoryLeft ON (idnr = MandatoryLeft.student)
  LEFT JOIN RecommendedPassed ON (idnr = RecommendedPassed.student)
  LEFT JOIN MathCredits ON (idnr = MathCredits.student)
  LEFT JOIN SeminarCourses ON (idnr = SeminarCourses.student))

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
