CREATE TABLE IF NOT EXISTS employees (
    id INT,
    name VARCHAR(100) NOT NULL,
    manager_id INT,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    hire_date DATE NOT NULL,

    PRIMARY KEY (id),
    FOREIGN KEY (manager_id)
        REFERENCES employees(id)
);

CREATE TABLE IF NOT EXISTS categories (
    id INT,
    name VARCHAR(100) NOT NULL,
    parent_id INT,

    PRIMARY KEY (id),
    FOREIGN KEY (parent_id)
        REFERENCES categories(id)
);

CREATE TABLE IF NOT EXISTS products (
    id INT,
    name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    created_at DATETIME NOT NULL,

    PRIMARY KEY (id),
    FOREIGN KEY (category_id)
        REFERENCES categories(id)
);

CREATE TABLE IF NOT EXISTS sales (
    id INT,
    product_id INT NOT NULL,
    employee_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2),

    PRIMARY KEY (id),
    FOREIGN KEY (product_id)
        REFERENCES products(id),
    FOREIGN KEY (employee_id)
        REFERENCES employees(id)
);

CREATE TABLE IF NOT EXISTS price_history (
    id INT,
    product_id INT NOT NULL,
    old_price DECIMAL(10, 2) NOT NULL,
    new_price DECIMAL(10, 2) NOT NULL,
    change_date DATETIME NOT NULL,
    changed_by VARCHAR(50) NOT NULL,

    PRIMARY KEY (id),
    FOREIGN KEY (product_id)
        REFERENCES products(id)
);
