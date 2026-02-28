-- Task 2.1

SELECT
    name,
    get_employee_exp(hire_date) AS experience,
    YEAR(hire_date) AS hired_in,
    YEAR(CURDATE()) AS current_year
FROM
    employees;

-- Task 2.2

SELECT
    id,
    name,
    price,
    discount_by(price, 15) AS discounted_by_15
FROM products;

-- Task 2.3

SELECT department INTO @ex_dep FROM employees LIMIT 1;
CALL get_employee_count_by_dep(@ex_dep, @ex_emp_count);

SELECT
    @ex_dep AS example_dep_name,
    @ex_emp_count AS employee_count;

-- Verify
SELECT
    COUNT(*)
FROM
    employees
WHERE
    department = @ex_dep;

-- Task 2.4

CALL change_category(1, 3);
SELECT * FROM products WHERE id = 1;
