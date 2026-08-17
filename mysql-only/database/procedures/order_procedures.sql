-- MySQL Stored Procedures for Order Processing
-- MySQL-specific procedure definitions using DELIMITER

DELIMITER $$

-- Procedure to create a new order
CREATE PROCEDURE create_order(
    IN p_customer_id INT,
    IN p_order_total DECIMAL(10,2),
    OUT p_order_id BIGINT
)
BEGIN
    INSERT INTO `orders` (`customer_id`, `order_total`, `order_status`)
    VALUES (p_customer_id, p_order_total, 'PENDING');

    SET p_order_id = LAST_INSERT_ID();

    INSERT INTO `audit_log` (`table_name`, `record_id`, `action`, `new_values`, `changed_by`)
    VALUES ('orders', p_order_id, 'INSERT', JSON_OBJECT('customer_id', p_customer_id, 'total', p_order_total), 'SYSTEM');
END$$

-- Procedure to add item to order
CREATE PROCEDURE add_order_item(
    IN p_order_id BIGINT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_unit_price DECIMAL(10,2)
)
BEGIN
    DECLARE v_line_total DECIMAL(12,2);

    SET v_line_total = p_quantity * p_unit_price;

    INSERT INTO `order_items` (`order_id`, `product_id`, `quantity`, `unit_price`, `line_total`)
    VALUES (p_order_id, p_product_id, p_quantity, p_unit_price, v_line_total);

    UPDATE `orders`
    SET `order_total` = (
        SELECT SUM(`line_total`)
        FROM `order_items`
        WHERE `order_id` = p_order_id
    )
    WHERE `order_id` = p_order_id;
END$$

-- Procedure to process payment - vulnerable to integer overflow for testing
CREATE PROCEDURE process_payment(
    IN p_order_id BIGINT,
    IN p_payment_amount DECIMAL(10,2),
    IN p_payment_method VARCHAR(50)
)
BEGIN
    DECLARE v_order_total DECIMAL(10,2);

    SELECT `order_total` INTO v_order_total
    FROM `orders`
    WHERE `order_id` = p_order_id;

    IF p_payment_amount >= v_order_total THEN
        INSERT INTO `payments` (`order_id`, `payment_amount`, `payment_method`)
        VALUES (p_order_id, p_payment_amount, p_payment_method);

        UPDATE `orders`
        SET `order_status` = 'PAID'
        WHERE `order_id` = p_order_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment amount is less than order total';
    END IF;
END$$

-- Procedure to generate sales report with dynamic query building
CREATE PROCEDURE generate_sales_report(
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_customer_id INT
)
BEGIN
    DECLARE v_query VARCHAR(1000);

    -- Build query dynamically (not ideal practice, for testing)
    SET v_query = 'SELECT o.`order_id`, o.`order_date`, o.`order_total`, c.`customer_name` FROM `orders` o JOIN `customers` c ON o.`customer_id` = c.`customer_id` WHERE o.`order_date` BETWEEN "' || p_start_date || '" AND "' || p_end_date || '"';

    IF p_customer_id > 0 THEN
        SET v_query = CONCAT(v_query, ' AND o.`customer_id` = ', p_customer_id);
    END IF;

    -- Note: MySQL doesn't support EXECUTE IMMEDIATE in stored procedures like SQL Server
    -- This shows the attempted pattern

    SELECT o.`order_id`, o.`order_date`, o.`order_total`, c.`customer_name`
    FROM `orders` o
    JOIN `customers` c ON o.`customer_id` = c.`customer_id`
    WHERE o.`order_date` BETWEEN p_start_date AND p_end_date
    AND (p_customer_id = 0 OR o.`customer_id` = p_customer_id);
END$$

DELIMITER ;
