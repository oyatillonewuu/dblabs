DROP FUNCTION IF EXISTS get_employee_exp;
DROP FUNCTION IF EXISTS discount_by;
DROP PROCEDURE IF EXISTS change_category;

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

CREATE PROCEDURE IF NOT EXISTS get_employee_count_by_dep(IN department VARCHAR(50), OUT count INT)
BEGIN
    SELECT
        COUNT(*) INTO count
    FROM
        employees
    WHERE
    employees.department = department;
END//

DELIMITER ;

-- Task 2.4

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS change_category(IN product_id INT, IN new_cat_id INT)
proc_label:BEGIN
    DECLARE cat_id INT DEFAULT NULL;
    DECLARE prod_id INT DEFAULT NULL;
    DECLARE exit INT DEFAULT 0;

    SELECT id INTO cat_id FROM categories WHERE id = new_cat_id;
    SELECT id INTO prod_id FROM products WHERE id = product_id;

    IF cat_id IS NULL THEN
        SELECT CONCAT("Category with ID = ", new_cat_id, " does not exist.") AS message;
        exit = 1;
    END IF;
    IF prod_id IS NULL THEN
        SELECT CONCAT("Product with ID = ", product_id, " does not exist.") AS message;
        exit = 1;
    END IF;

    IF exit = 1 THEN
        LEAVE proc_label;
    END IF;

END//

DELIMITER ;
