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