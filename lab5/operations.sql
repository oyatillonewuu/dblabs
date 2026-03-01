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

-- Task 3.1-2

SELECT @ex_id := id FROM products LIMIT 1;

SELECT *
FROM products
WHERE id = @ex_id;

UPDATE products
SET price = price + 1
WHERE id = @ex_id;

SELECT *
FROM products
WHERE id = @ex_id;

SELECT *
FROM price_history
WHERE product_id = @ex_id;

-- Task 3.3
-- ON INSERT
-- Expected: Raises error on negative value for stock/price.

SELECT @ex_id := id FROM products LIMIT 1;
SELECT @ex_cat_id := category_id FROM products WHERE id = @ex_id LIMIT 1;

SELECT COUNT(*) AS product_count_before_invalid_insert FROM products;

INSERT INTO products
    (name, category_id, price, stock, created_at)
VALUES
    ("example product (neg stock)", @ex_cat_id, 172, -100, NOW());

INSERT INTO products
    (name, category_id, price, stock, created_at)
VALUES
    ("example product (neg price)", @ex_cat_id, -172, 100, NOW());

SELECT COUNT(*) AS product_count_after_invalid_insert FROM products;

-- ON UPDATE
-- Expected: Raises error on negative value for stock/price.

UPDATE products SET price = -256 WHERE id = @ex_id;
UPDATE products SET stock = -256 WHERE id = @ex_id;

-- Task 3.4

SELECT @ex_id := id FROM products WHERE stock > 5 LIMIT 1;
SELECT @ex_emp_id := id FROM employees LIMIT 1;

SELECT id, stock AS stock_before FROM products WHERE id = @ex_id;

INSERT INTO sales
    (product_id, employee_id, sale_date, quantity, total_amount)
VALUES
    (@ex_id, @ex_emp_id, CURDATE(), 3, 10.0);

SELECT id, stock AS stock_after_success FROM products WHERE id = @ex_id;

INSERT INTO sales
    (product_id, employee_id, sale_date, quantity, total_amount)
VALUES
    (@ex_id, @ex_emp_id, CURDATE(), 3000000, 10.0);

SELECT id, stock AS stock_after_invalid_attempt FROM products WHERE id = @ex_id;

-- Task 4.1

SELECT
    id,
    name,
    department,
    salary,
    RANK()
        OVER (
            PARTITION BY department
            ORDER BY salary DESC
        ) AS dept_rank
FROM employees;

-- Task 4.2

SELECT
    id,
    name,
    salary,
    RANK()
        OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

SELECT
    id,
    name,
    salary,
    DENSE_RANK()
        OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

SELECT
    id,
    name,
    salary,
    ROW_NUMBER()
        OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

-- Task 4.3

WITH ranked_employees AS (
    SELECT
        id,
        name,
        salary,
        department,
        RANK()
            OVER (
                PARTITION BY department
                ORDER BY salary DESC
            ) AS dept_rank
    FROM employees
)
SELECT * FROM ranked_employees WHERE dept_rank = 1;
