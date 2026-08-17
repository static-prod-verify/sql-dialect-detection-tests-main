-- PostgreSQL Inventory Schema (Unsupported)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE TYPE product_status AS ENUM ('ACTIVE', 'DISCONTINUED');

CREATE TABLE inventory (
    product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_name VARCHAR NOT NULL,
    status product_status NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE FUNCTION get_active_products() RETURNS TABLE (id UUID, name VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT product_id, product_name FROM inventory WHERE status = 'ACTIVE';
END;
$$ LANGUAGE plpgsql;
