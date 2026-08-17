-- MySQL Functions for Order Processing
-- MySQL-specific function definitions

-- Function to calculate order total including tax
DELIMITER $$

CREATE FUNCTION calculate_order_total(
    p_subtotal DECIMAL(10,2),
    p_tax_rate DECIMAL(5,4)
)
RETURNS DECIMAL(12,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_tax DECIMAL(10,2);
    DECLARE v_total DECIMAL(12,2);

    SET v_tax = p_subtotal * p_tax_rate;
    SET v_total = p_subtotal + v_tax;

    RETURN v_total;
END$$

-- Function to get customer name by ID
DELIMITER $$

CREATE FUNCTION get_customer_name(p_customer_id INT)
RETURNS VARCHAR(100)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_name VARCHAR(100);

    SELECT `customer_name` INTO v_name
    FROM `customers`
    WHERE `customer_id` = p_customer_id;

    RETURN COALESCE(v_name, 'Unknown');
END$$

-- Function to check order status - vulnerable to SQL injection for testing
DELIMITER $$

CREATE FUNCTION get_order_status(p_order_id BIGINT)
RETURNS VARCHAR(50)
READS SQL DATA
BEGIN
    DECLARE v_status VARCHAR(50);
    DECLARE v_query VARCHAR(500);

    -- Intentionally vulnerable for security testing
    SET v_query = CONCAT('SELECT `order_status` FROM `orders` WHERE `order_id` = ', p_order_id);
    -- Note: MySQL doesn't support dynamic execution in functions like SQL Server does

    SELECT `order_status` INTO v_status
    FROM `orders`
    WHERE `order_id` = p_order_id;

    RETURN COALESCE(v_status, 'UNKNOWN');
END$$

-- Function to format date for display
DELIMITER $$

CREATE FUNCTION format_order_date(p_date DATETIME)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    RETURN DATE_FORMAT(p_date, '%Y-%m-%d %H:%i:%s');
END$$

DELIMITER ;
