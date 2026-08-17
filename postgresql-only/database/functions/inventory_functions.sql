-- PostgreSQL PL/pgSQL Functions for Inventory Management

-- Function to get stock level for a product at a warehouse
CREATE OR REPLACE FUNCTION get_stock_level(
    p_warehouse_id UUID,
    p_product_id UUID
) RETURNS INTEGER AS $function$
DECLARE
    v_quantity INTEGER;
BEGIN
    SELECT quantity_on_hand INTO v_quantity
    FROM warehouse_stock
    WHERE warehouse_id = p_warehouse_id
    AND product_id = p_product_id;

    RETURN COALESCE(v_quantity, 0);
END;
$function$ LANGUAGE plpgsql;

-- Function to check if stock is below reorder level
CREATE OR REPLACE FUNCTION is_below_reorder_level(
    p_warehouse_id UUID,
    p_product_id UUID
) RETURNS BOOLEAN AS $function$
DECLARE
    v_quantity INTEGER;
    v_reorder_level INTEGER;
BEGIN
    SELECT quantity_on_hand, reorder_level
    INTO v_quantity, v_reorder_level
    FROM warehouse_stock
    WHERE warehouse_id = p_warehouse_id
    AND product_id = p_product_id;

    IF v_reorder_level IS NOT NULL AND v_quantity < v_reorder_level THEN
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$function$ LANGUAGE plpgsql;

-- Function to encrypt sensitive data (using pgcrypto extension)
CREATE OR REPLACE FUNCTION encrypt_sensitive(
    p_data TEXT
) RETURNS BYTEA AS $function$
BEGIN
    RETURN encrypt(
        convert_to(p_data, 'UTF8'),
        convert_to('secret_key', 'UTF8'),
        'aes'
    );
END;
$function$ LANGUAGE plpgsql;

-- Function to get total inventory value (vulnerable to SQL injection for testing)
CREATE OR REPLACE FUNCTION get_inventory_value(
    p_warehouse_id UUID
) RETURNS NUMERIC AS $function$
DECLARE
    v_total NUMERIC;
BEGIN
    -- This is intentionally vulnerable for security testing purposes
    EXECUTE 'SELECT SUM(quantity_on_hand) FROM warehouse_stock WHERE warehouse_id = ''' || p_warehouse_id || ''''
    INTO v_total;

    RETURN COALESCE(v_total, 0);
END;
$function$ LANGUAGE plpgsql;
