CREATE TABLE Students(
  idnr TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  login TEXT NOT NULL UNIQUE
);

CREATE TABLE Programs(
  name TEXT PRIMARY KEY,
  abbreviation TEXT NOT NULL
);

CREATE TABLE StudentPrograms(
  student TEXT NOT NULL UNIQUE,
  program TEXT NOT NULL,
  FOREIGN KEY(student) REFERENCES Students(idnr),
  FOREIGN KEY(program) REFERENCES Programs(name),
  PRIMARY KEY(student, program)
);

CREATE TABLE Branches(
  name TEXT NOT NULL,
  program TEXT NOT NULL,
  FOREIGN KEY(program) REFERENCES Programs(name),
  PRIMARY KEY(name, program)
);


CREATE TABLE StudentBranches(
  student TEXT NOT NULL,
  branch TEXT NOT NULL,
  program TEXT NOT NULL,
  FOREIGN KEY (student, program) REFERENCES StudentPrograms(student, program),
  PRIMARY KEY (student)
);

CREATE TABLE Departments(
  name TEXT PRIMARY KEY,
  abbreviation TEXT NOT NULL UNIQUE
);

CREATE TABLE Courses(
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  credits NUMERIC NOT NULL
);

CREATE TABLE LimitedCourses(
  code TEXT PRIMARY KEY,
  capacity INT NOT NULL,
  FOREIGN KEY(code) REFERENCES Courses(code)
);

CREATE TABLE DepartmentCourses(
  course TEXT PRIMARY KEY,
  department TEXT NOT NULL,
  FOREIGN KEY(course) REFERENCES Courses(code),
  FOREIGN KEY(department) REFERENCES Departments(name)
);

CREATE TABLE Registered(
  student TEXT,
  course TEXT,
  FOREIGN KEY(student) REFERENCES Students(idnr),
  FOREIGN KEY(course) REFERENCES Courses(code),
  PRIMARY KEY(student, course)
);

CREATE TABLE Classifications(
  name TEXT PRIMARY KEY
);

CREATE TABLE ClassifiedCourses(
  course TEXT,
  classification TEXT,
  FOREIGN KEY(course) REFERENCES Courses(code),
  FOREIGN KEY(classification) REFERENCES Classifications(name),
  PRIMARY KEY(course, classification)
);

CREATE TABLE ProgramMandatory(
  course TEXT,
  program TEXT NOT NULL,
  FOREIGN KEY(course) REFERENCES Courses(code),
  PRIMARY KEY(course, program)
);

CREATE TABLE Recommended(
  course TEXT,
  branch TEXT,
  program TEXT,
  FOREIGN KEY(course) REFERENCES Courses(code),
  FOREIGN KEY(branch, program) REFERENCES Branches(name, program),
  PRIMARY KEY(course, branch, program)
);

CREATE TABLE BranchMandatory(
  course TEXT,
  branch TEXT,
  program TEXT,
  FOREIGN KEY(course) REFERENCES Courses(code),
  FOREIGN KEY(branch, program) REFERENCES Branches(name, program),
  PRIMARY KEY(course, branch, program)
);

CREATE TABLE WaitingList (
  student TEXT,
  course TEXT,
  position INT NOT NULL,
  FOREIGN KEY(student) REFERENCES Students(idnr),
  FOREIGN KEY(course) REFERENCES LimitedCourses(code),
  UNIQUE (course, position),
  PRIMARY KEY (student, course)
);

CREATE TABLE Taken (
  student TEXT,
  course TEXT,
  grade TEXT NOT NULL,
  FOREIGN KEY(student) REFERENCES Students(idnr),
  FOREIGN KEY(course) REFERENCES Courses(code),
  PRIMARY KEY (student, course),
  CHECK ( grade IN ('U', '3', '4', '5') )
);

