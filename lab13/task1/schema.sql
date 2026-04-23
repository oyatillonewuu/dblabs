CREATE TABLE IF NOT EXISTS Product (
    id INT AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,

    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS Customer (
    id INT AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,

    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS Time (
    id INT AUTO_INCREMENT,
    datetime_value DATETIME NOT NULL,

    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS SalesFact (
    product_id INT,
    customer_id INT,
    time_id INT,

    PRIMARY KEY (product_id, customer_id, time_id),
    FOREIGN KEY (product_id)
        REFERENCES Product(id),
    FOREIGN KEY (customer_id)
        REFERENCES Customer(id),
    FOREIGN KEY (time_id)
        REFERENCES Time(id)
);
