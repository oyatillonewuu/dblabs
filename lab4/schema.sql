CREATE TABLE IF NOT EXISTS departments (
    department_id INT AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,

    PRIMARY KEY (department_id)
);

CREATE TABLE IF NOT EXISTS students (
    student_id INT AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120),
    enrollment_year INT,
    department_id INT,

    PRIMARY KEY (student_id),
    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);

CREATE TABLE IF NOT EXISTS courses (
    course_id INT AUTO_INCREMENT,
    course_name VARCHAR(120) NOT NULL,
    credits INT NOT NULL,
    max_seats INT NOT NULL,
    department_id INT,

    PRIMARY KEY (course_id),
    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);

CREATE TABLE IF NOT EXISTS enrollments (
    enrollment_id INT AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    grade DECIMAL(4, 2),
    enrollment_date DATE,

    PRIMARY KEY (enrollment_id),
    FOREIGN KEY (student_id)
        REFERENCES students(student_id),
    FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
);
