-- Produced by Claude Sonnet 4.6

-- Products
INSERT INTO Product (name) VALUES
('Laptop'),
('Mouse'),
('Keyboard'),
('Monitor'),
('Headset');

-- Customers
INSERT INTO Customer (name) VALUES
('Alice Johnson'),
('Bob Smith'),
('Carol White'),
('David Brown'),
('Eva Martinez');

-- Time dimension
INSERT INTO Time (datetime_value) VALUES
('2024-01-05 09:15:00'),
('2024-01-12 14:30:00'),
('2024-02-03 11:00:00'),
('2024-02-20 16:45:00'),
('2024-03-08 10:20:00'),
('2024-03-15 13:00:00'),
('2024-04-02 09:50:00'),
('2024-04-18 15:30:00');

-- Sales facts (product_id, customer_id, time_id)
INSERT INTO SalesFact (product_id, customer_id, time_id) VALUES
(1, 1, 1),  -- Alice bought Laptop  on Jan 5
(2, 1, 2),  -- Alice bought Mouse    on Jan 12
(3, 2, 2),  -- Bob   bought Keyboard on Jan 12
(4, 3, 3),  -- Carol bought Monitor  on Feb 3
(2, 4, 4),  -- David bought Mouse    on Feb 20
(5, 4, 5),  -- David bought Headset  on Mar 8
(1, 5, 6),  -- Eva   bought Laptop   on Mar 15
(3, 5, 7),  -- Eva   bought Keyboard on Apr 2
(4, 2, 8),  -- Bob   bought Monitor  on Apr 18
(5, 3, 8);  -- Carol bought Headset  on Apr 18
