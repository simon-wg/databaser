CREATE TABLE Students(
  idnr TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  login TEXT NOT NULL,
  program TEXT NOT NULL
);

CREATE TABLE Branches(
  name TEXT,
  program TEXT,
  PRIMARY KEY (name, program)
);

CREATE TABLE Courses(
  code TEXT PRIMARY KEY,
  name TEXT,
  credits NUMERIC,
  department TEXT
);

CREATE TABLE LimitedCourses(
  FOREIGN KEY(code) REFERENCES Courses(code),
  capacity INT
  PRIMARY KEY(code)
);

CREATE TABLE StudentBranches(
  FOREIGN KEY(student) REFERENCES Students(idnr),
  FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
  PRIMARY KEY(student)
);

CREATE TABLE Classifications(
  name TEXT PRIMARY KEY,
);

CREATE TABLE MandatoryProgram(
  FOREIGN KEY(course) REFERENCES Courses(code)
  program TEXT,
  PRIMARY KEY((course, program))
);

CREATE TABLE MandatoryBranch(
  FOREIGN KEY(course) REFERENCES Courses(code)
  FOREIGN KEY((branch, program)) REFERENCES Branches((name, program))
  PRIMARY KEY((course, branch, progranm))
);

CREATE TABLE Registered(
  FOREIGN KEY(student) REFERENCES Students(idnr)
  FOREIGN KEY(course) REFERENCES Courses(code)
  PRIMARY KEY((student, course))
);

CREATE TABLE Taken (
  FOREIGN KEY(student) REFERENCES Students(idnr),
  FOREIGN KEY(course) REFERENCES Courses(code)
  grade TEXT,
  PRIMARY KEY((student, course))
);

CREATE TABLE WaitingList (
  FOREIGN KEY(student) REFERENCES Students(idnr),
  FOREIGN KEY(course) REFERENCES LimitedCourses(code),
  position INT,
  PRIMARY KEY(student, course)
);
