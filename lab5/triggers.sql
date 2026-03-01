DROP TRIGGER IF EXISTS price_hist_add;
DROP TRIGGER IF EXISTS stock_price_ins_prevent_neg;
DROP TRIGGER IF EXISTS stock_price_upd_prevent_neg;
DROP TRIGGER IF EXISTS sale_on_zero_stock_prevent;
DROP TRIGGER IF EXISTS stock_auto_upd;

-- Task 3.1
-- Task 3.2

DELIMITER //

CREATE TRIGGER IF NOT EXISTS price_hist_add
AFTER UPDATE
ON products
FOR EACH ROW
BEGIN
    IF OLD.price != NEW.price THEN
        INSERT INTO price_history (product_id, old_price, new_price, change_date)
        VALUES (NEW.id, OLD.price, NEW.price, NOW());
    END IF;
END//

DELIMITER ;

-- Task 3.3

DELIMITER //

CREATE TRIGGER IF NOT EXISTS stock_price_ins_prevent_neg
BEFORE INSERT
ON products
FOR EACH ROW
BEGIN
    IF NEW.stock < 0 OR NEW.price < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Stock and Price must be nonnegative.';
    END IF;
END//

CREATE TRIGGER IF NOT EXISTS stock_price_upd_prevent_neg
BEFORE UPDATE
ON products
FOR EACH ROW
BEGIN
    IF NEW.stock < 0 OR NEW.price < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Stock and Price must be nonnegative.';
    END IF;
END//

DELIMITER ;

-- Task 3.4

DELIMITER //

CREATE TRIGGER IF NOT EXISTS sale_on_zero_stock_prevent
BEFORE INSERT
ON sales
FOR EACH ROW
BEGIN
    DECLARE curr_stock INT DEFAULT NULL;
    SELECT stock INTO curr_stock FROM products where id = NEW.product_id;
    IF curr_stock IS NULL OR curr_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient stocks for sale.';
    END IF;
END//

CREATE TRIGGER IF NOT EXISTS stock_auto_upd
AFTER INSERT
ON sales
FOR EACH ROW
BEGIN
    UPDATE products
    SET products.stock = (products.stock - NEW.quantity)
    WHERE products.id = NEW.product_id;
END//

DELIMITER ;
