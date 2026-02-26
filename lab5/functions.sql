DROP FUNCTION IF EXISTS get_employee_exp;
DROP FUNCTION IF EXISTS discount_by;

-- Task 2.1

CREATE FUNCTION IF NOT EXISTS get_employee_exp(hire_date DATE)
RETURNS INT
DETERMINISTIC
RETURN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) + 1;

-- Task 2.2

DELIMITER //

CREATE FUNCTION IF NOT EXISTS discount_by(price DECIMAL(10, 2), discount INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE result DECIMAL(10, 2);
    SET result = ((100 - discount) * price)/100;
    RETURN result;
END//

DELIMITER ;

-- Task 2.3
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS get_employee_count_by_dep(department VARCHAR(50), OUT count INT)
BEGIN
    SELECT
        COUNT(*) INTO count
    FROM
        employees
    WHERE
    employees.department = department;
END//

DELIMITER ;
