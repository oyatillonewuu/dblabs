CREATE TABLE IF NOT EXISTS patient (
    id INT AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    birth_date DATE,

    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS doctor (
    id INT AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100) NOT NULL,

    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS ward (
    id INT AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    total_beds INT CHECK (total_beds > 0),

    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS admission (
    id INT AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    ward_id INT NOT NULL,
    date DATE NOT NULL,
    discharge_date DATE,

    PRIMARY KEY (id),
    FOREIGN KEY (patient_id)
        REFERENCES patient(id),
    FOREIGN KEY (doctor_id)
        REFERENCES doctor(id),
    FOREIGN KEY (ward_id)
        REFERENCES ward(id)
);
