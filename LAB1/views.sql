CREATE VIEW BasicInformation AS
  SELECT idnr, name, login, Students.program, branch FROM Students LEFT JOIN StudentBranches ON (idnr = student);
