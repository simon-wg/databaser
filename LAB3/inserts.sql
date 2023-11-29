INSERT INTO Programs VALUES ('Prog1', 'P1');
INSERT INTO Programs VALUES ('Prog2', 'P2');

INSERT INTO Departments VALUES ('Dep1', 'D1');

INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');

INSERT INTO Students VALUES ('1111111111','N1','ls1');
INSERT INTO Students VALUES ('2222222222','N2','ls2');
INSERT INTO Students VALUES ('3333333333','N3','ls3');
INSERT INTO Students VALUES ('4444444444','N4','ls4');
INSERT INTO Students VALUES ('5555555555','Nx','ls5');
INSERT INTO Students VALUES ('6666666666','Nx','ls6');

INSERT INTO StudentPrograms VALUES ('1111111111','Prog1');
INSERT INTO StudentPrograms VALUES ('2222222222','Prog1');
INSERT INTO StudentPrograms VALUES ('3333333333','Prog2');
INSERT INTO StudentPrograms VALUES ('4444444444','Prog1');
INSERT INTO StudentPrograms VALUES ('5555555555','Prog2');
INSERT INTO StudentPrograms VALUES ('6666666666','Prog2');

INSERT INTO StudentBranches VALUES ('2222222222','B1', 'Prog1');
INSERT INTO StudentBranches VALUES ('3333333333','B1', 'Prog2');
INSERT INTO StudentBranches VALUES ('4444444444','B1', 'Prog1');
INSERT INTO StudentBranches VALUES ('5555555555','B1', 'Prog2');

INSERT INTO Courses VALUES ('CCC111','C1',22.5);
INSERT INTO Courses VALUES ('CCC222','C2',20);
INSERT INTO Courses VALUES ('CCC333','C3',30);
INSERT INTO Courses VALUES ('CCC444','C4',60);
INSERT INTO Courses VALUES ('CCC555','C5',50);

INSERT INTO Prerequisites VALUES ('CCC444', 'CCC111');
INSERT INTO Prerequisites VALUES ('CCC444', 'CCC222');

INSERT INTO DepartmentCourses VALUES ('CCC111', 'Dep1');
INSERT INTO DepartmentCourses VALUES ('CCC222', 'Dep1');
INSERT INTO DepartmentCourses VALUES ('CCC333', 'Dep1');
INSERT INTO DepartmentCourses VALUES ('CCC444', 'Dep1');
INSERT INTO DepartmentCourses VALUES ('CCC555', 'Dep1');

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO ClassifiedCourses VALUES ('CCC333','math');
INSERT INTO ClassifiedCourses VALUES ('CCC444','math');
INSERT INTO ClassifiedCourses VALUES ('CCC444','research');
INSERT INTO ClassifiedCourses VALUES ('CCC444','seminar');


INSERT INTO ProgramMandatory VALUES ('CCC111','Prog1');

INSERT INTO BranchMandatory VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO BranchMandatory VALUES ('CCC444', 'B1', 'Prog2');

INSERT INTO Recommended VALUES ('CCC222', 'B1', 'Prog1');
INSERT INTO Recommended VALUES ('CCC333', 'B1', 'Prog2');

INSERT INTO Registered VALUES ('1111111111','CCC111');
INSERT INTO Registered VALUES ('1111111111','CCC222');
INSERT INTO Registered VALUES ('1111111111','CCC333');
INSERT INTO Registered VALUES ('2222222222','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC333');

INSERT INTO Taken VALUES('4444444444','CCC111','5');
INSERT INTO Taken VALUES('4444444444','CCC222','5');
INSERT INTO Taken VALUES('4444444444','CCC333','5');
INSERT INTO Taken VALUES('4444444444','CCC444','5');

INSERT INTO Taken VALUES('5555555555','CCC111','5');
INSERT INTO Taken VALUES('5555555555','CCC222','4');
INSERT INTO Taken VALUES('5555555555','CCC444','3');

INSERT INTO Taken VALUES('2222222222','CCC111','U');
INSERT INTO Taken VALUES('2222222222','CCC222','U');
INSERT INTO Taken VALUES('2222222222','CCC444','U');

INSERT INTO WaitingList VALUES('3333333333','CCC222', 100000);
INSERT INTO Registered VALUES('3333333333','CCC333');
INSERT INTO Registered VALUES('2222222222','CCC333');
