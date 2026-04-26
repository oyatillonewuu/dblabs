-- Uses the schema defined in ../task1/schema.sql

-- Slice: Sales in 2024

SELECT
    s.*, t.datetime_value
FROM
    SalesFact AS s
INNER JOIN
    Time AS t
    ON s.time_id = t.id
WHERE
    YEAR(t.datetime_value) = 2024;

-- Dice: Sales in 2024 AND Product='Laptop'

SELECT
    s.*, p.name AS product_name, t.datetime_value AS sold_at
FROM
    SalesFact AS s
INNER JOIN
    Time AS t
    ON s.time_id = t.id
INNER JOIN
    Product AS p
    ON s.product_id = p.id
WHERE
    YEAR(t.datetime_value) = 2024
    AND
    p.name = 'Laptop';

-- Roll-up: total sales per product category

SELECT
    p.name, COUNT(s.product_id) AS sales_count
FROM
    Product AS p
LEFT JOIN
    SalesFact AS s
    ON p.id = s.product_id
GROUP BY
    p.name;

-- Drill-down: Monthly sales for 2024

SELECT
    p.name,  MONTHNAME(t.datetime_value) AS month, COUNT(s.product_id) AS sales_count
FROM
    Product AS p
LEFT JOIN
    SalesFact AS s
    ON p.id = s.product_id
LEFT JOIN
    Time AS t
    ON s.time_id = t.id
WHERE
    YEAR(t.datetime_value) = 2024
GROUP BY
    p.name, MONTHNAME(t.datetime_value);
