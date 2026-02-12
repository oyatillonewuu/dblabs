CREATE TABLE Department (
    dept_id     INT,
    dept_name   VARCHAR(50) NOT NULL,
    building    VARCHAR(50),
    budget      DECIMAL(12, 2),

    PRIMARY KEY (dept_id)
);

CREATE TABLE Instructor (
    instructor_id   INT,
    name            VARCHAR(50) NOT NULL,
    dept_id         INT NULL,
    salary          DECIMAL(12, 2),
    hire_date       DATE DEFAULT (CURRENT_DATE()),

    PRIMARY KEY (instructor_id),

    FOREIGN KEY (dept_id)
        REFERENCES Department(dept_id)
        ON DELETE SET NULL
);

CREATE TABLE Course (
    course_id       VARCHAR(50),
    title           VARCHAR(50) NOT NULL, -- does not make sense if title is missing
    dept_id         INT,
    credits         INT CHECK (credits >= 0),
    instructor_id   INT NULL,
    
    PRIMARY KEY (course_id),

    FOREIGN KEY (dept_id)
        REFERENCES Department(dept_id)
        ON DELETE CASCADE,

    FOREIGN KEY (instructor_id)
        REFERENCES Instructor(instructor_id)
        ON DELETE SET NULL
);

CREATE TABLE Student (
    student_id      INT,
    name            VARCHAR(50) NOT NULL,
    dept_id         INT NULL,
    enrollment_year INT,
    total_credits   INT CHECK (total_credits >= 0),
    advisor_id      INT NULL,

    PRIMARY KEY (student_id),

    FOREIGN KEY (dept_id)
        REFERENCES Department(dept_id)
        ON DELETE SET NULL,

    FOREIGN KEY (advisor_id)
        REFERENCES Instructor(instructor_id)
        ON DELETE SET NULL
);

CREATE TABLE Takes (
    student_id      INT,
    course_id       VARCHAR(50),
    semester        VARCHAR(50),
    year            INT,
    grade           CHAR(2),

    PRIMARY KEY (student_id, course_id, semester, year),

    FOREIGN KEY (student_id)
        REFERENCES Student(student_id)
        ON DELETE CASCADE,

    FOREIGN KEY (course_id)
        REFERENCES Course(course_id)
        ON DELETE RESTRICT
);

CREATE TABLE Prerequisite (
    course_id       VARCHAR(50),
    prereq_id       VARCHAR(50),
    min_grade       CHAR(2),

    PRIMARY KEY (course_id, prereq_id),
    FOREIGN KEY (course_id)
        REFERENCES Course(course_id)
        ON DELETE CASCADE,
    FOREIGN KEY (prereq_id)
        REFERENCES Course(course_id)
        ON DELETE RESTRICT
);