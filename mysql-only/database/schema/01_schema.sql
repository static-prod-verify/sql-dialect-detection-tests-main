-- MySQL Order Management System Schema
-- Demonstrates MySQL-specific features that distinguish it from T-SQL and PL/SQL

-- Create database (MySQL-specific)
-- CREATE DATABASE IF NOT EXISTS order_system;
-- USE order_system;

-- Customers table with MySQL-specific features
CREATE TABLE IF NOT EXISTS `customers` (
    `customer_id` INT AUTO_INCREMENT PRIMARY KEY,
    `customer_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) UNIQUE,
    `phone` VARCHAR(20),
    `registration_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `country` VARCHAR(100),
    `city` VARCHAR(100),
    `postal_code` VARCHAR(20),
    `status` CHAR(1) NOT NULL DEFAULT 'A',
    KEY `idx_email` (`email`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Orders table
CREATE TABLE IF NOT EXISTS `orders` (
    `order_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `customer_id` INT NOT NULL,
    `order_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `order_total` DECIMAL(10,2),
    `order_status` VARCHAR(20),
    `shipping_date` DATETIME,
    `tracking_number` VARCHAR(50),
    CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`)
        REFERENCES `customers` (`customer_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Order Items table
CREATE TABLE IF NOT EXISTS `order_items` (
    `item_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL,
    `product_id` INT NOT NULL,
    `quantity` INT NOT NULL CHECK (quantity > 0),
    `unit_price` DECIMAL(10,2),
    `line_total` DECIMAL(12,2),
    CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`)
        REFERENCES `orders` (`order_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Products table
CREATE TABLE IF NOT EXISTS `products` (
    `product_id` INT AUTO_INCREMENT PRIMARY KEY,
    `product_code` VARCHAR(20) UNIQUE NOT NULL,
    `product_name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `unit_price` DECIMAL(10,2),
    `stock_level` INT DEFAULT 0,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Payments table
CREATE TABLE IF NOT EXISTS `payments` (
    `payment_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL,
    `payment_amount` DECIMAL(10,2),
    `payment_date` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `payment_method` VARCHAR(50),
    `transaction_id` VARCHAR(100),
    CONSTRAINT `fk_payments_order` FOREIGN KEY (`order_id`)
        REFERENCES `orders` (`order_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Audit Log table
CREATE TABLE IF NOT EXISTS `audit_log` (
    `log_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `table_name` VARCHAR(100) NOT NULL,
    `record_id` BIGINT NOT NULL,
    `action` ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    `old_values` JSON,
    `new_values` JSON,
    `changed_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `changed_by` VARCHAR(100),
    KEY `idx_table_record` (`table_name`, `record_id`),
    KEY `idx_changed_at` (`changed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create indexes for performance
CREATE INDEX `idx_order_customer` ON `orders`(`customer_id`);
CREATE INDEX `idx_order_date` ON `orders`(`order_date`);
CREATE INDEX `idx_order_items_order` ON `order_items`(`order_id`);
CREATE INDEX `idx_order_items_product` ON `order_items`(`product_id`);
CREATE INDEX `idx_product_code` ON `products`(`product_code`);
