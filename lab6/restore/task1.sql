CREATE TABLE IF NOT EXISTS department (
    id INT AUTO_INCREMENT,
    name VARCHAR(50),

    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS employee (
    id INT AUTO_INCREMENT,
    name VARCHAR(50),
    birth_date DATE,
    department_id INT NOT NULL, -- ensures total participation and exactly one department

    PRIMARY KEY (id),
    FOREIGN KEY (department_id)
        REFERENCES department(id)
);

CREATE TABLE IF NOT EXISTS manages (
    employee_id INT,
    department_id INT,

    PRIMARY KEY (department_id), -- only need department_id since this is one-to-many relationship
    FOREIGN KEY (employee_id)
        REFERENCES employee(id),
    FOREIGN KEY (department_id)
        REFERENCES department(id)
);

CREATE TABLE IF NOT EXISTS project (
    id INT AUTO_INCREMENT,
    name VARCHAR(100),
    budget DECIMAL(12, 2),

    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS assignment (
    employee_id INT,
    project_id INT,
    hours_worked INT CHECK (hours_worked >= 0), -- ensure non-negative

    PRIMARY KEY (employee_id, project_id),
    FOREIGN KEY (employee_id)
        REFERENCES employee(id),
    FOREIGN KEY (project_id)
        REFERENCES project(id)
);

