-- Task 2.1

SELECT
    name,
    get_employee_exp(hire_date) AS experience,
    YEAR(hire_date) AS hired_in,
    YEAR(CURDATE()) AS current_year
FROM
    employees;
