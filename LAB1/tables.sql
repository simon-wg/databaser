CREATE TABLE Students(
  idnr TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  login TEXT NOT NULL UNIQUE,
  program TEXT NOT NULL
);

CREATE TABLE Branches(
  name TEXT NOT NULL,
  program TEXT,
  PRIMARY KEY(name, program)
);

CREATE TABLE Courses(
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  credits NUMERIC NOT NULL,
  department TEXT NOT NULL
);

CREATE TABLE LimitedCourses(
  code TEXT PRIMARY KEY,
  capacity INT NOT NULL,
  FOREIGN KEY(code) REFERENCES Courses(code)
);

CREATE TABLE StudentBranches(
  student TEXT PRIMARY KEY,
  branch TEXT NOT NULL,
  program TEXT NOT NULL,
  FOREIGN KEY(student) REFERENCES Students(idnr),
  FOREIGN KEY(branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE Classifications(
  name TEXT PRIMARY KEY
);

CREATE TABLE Classified (
  course TEXT,
  classification TEXT,
  FOREIGN KEY(course) REFERENCES Courses(code),
  FOREIGN KEY(classification) REFERENCES Classifications(name),
  PRIMARY KEY(course, classification)
);

CREATE TABLE MandatoryProgram(
  course TEXT,
  program TEXT NOT NULL,
  FOREIGN KEY(course) REFERENCES Courses(code),
  PRIMARY KEY(course, program)
);

CREATE TABLE MandatoryBranch(
  course TEXT,
  branch TEXT,
  program TEXT,
  FOREIGN KEY(course) REFERENCES Courses(code),
  FOREIGN KEY(branch, program) REFERENCES Branches(name, program),
  PRIMARY KEY(course, branch, program)
);

CREATE TABLE RecommendedBranch(
  course TEXT,
  branch TEXT,
  program TEXT,
  FOREIGN KEY(course) REFERENCES Courses(code),
  FOREIGN KEY(branch, program) REFERENCES Branches(name, program),
  PRIMARY KEY(course, branch, program)
);

CREATE TABLE Registered(
  student TEXT,
  course TEXT,
  FOREIGN KEY(student) REFERENCES Students(idnr),
  FOREIGN KEY(course) REFERENCES Courses(code),
  PRIMARY KEY(student, course)
);

CREATE TABLE Taken (
  student TEXT,
  course TEXT,
  grade TEXT NOT NULL,
  FOREIGN KEY(student) REFERENCES Students(idnr),
  FOREIGN KEY(course) REFERENCES Courses(code),
  PRIMARY KEY(student, course),
  UNIQUE(student, course)
);

CREATE TABLE WaitingList (
  student TEXT,
  course TEXT,
  position INT NOT NULL,
  FOREIGN KEY(student) REFERENCES Students(idnr),
  FOREIGN KEY(course) REFERENCES LimitedCourses(code),
  PRIMARY KEY(student, course)
);
