DROP FUNCTION IF EXISTS get_employee_exp;

-- Task 2.1

CREATE FUNCTION IF NOT EXISTS get_employee_exp(hire_date DATE)
RETURNS INT
DETERMINISTIC
RETURN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) + 1;

SELECT
    name,
    get_employee_exp(hire_date) AS experience,
    YEAR(hire_date) AS hired_in,
    YEAR(CURDATE()) AS current_year
FROM
    employees;
