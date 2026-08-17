-- PostgreSQL PL/pgSQL Stored Procedures for Inventory Management

-- Procedure to record inventory movement
CREATE OR REPLACE PROCEDURE record_inventory_movement(
    p_stock_id UUID,
    p_quantity_changed INTEGER,
    p_reason VARCHAR
) LANGUAGE plpgsql AS $procedure$
BEGIN
    INSERT INTO inventory_movement (stock_id, quantity_changed, movement_reason)
    VALUES (p_stock_id, p_quantity_changed, p_reason);

    UPDATE warehouse_stock
    SET quantity_on_hand = quantity_on_hand + p_quantity_changed,
        updated_at = CURRENT_TIMESTAMP
    WHERE stock_id = p_stock_id;

    COMMIT;
END;
$procedure$;

-- Procedure to log audit trail
CREATE OR REPLACE PROCEDURE log_audit_trail(
    p_table_name VARCHAR,
    p_record_id UUID,
    p_action audit_action,
    p_old_values JSONB,
    p_new_values JSONB,
    p_changed_by VARCHAR
) LANGUAGE plpgsql AS $procedure$
BEGIN
    INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, changed_by)
    VALUES (p_table_name, p_record_id, p_action, p_old_values, p_new_values, p_changed_by);

    COMMIT;
END;
$procedure$;

-- Procedure to generate low stock alert
CREATE OR REPLACE PROCEDURE generate_low_stock_alerts()
LANGUAGE plpgsql AS $procedure$
DECLARE
    v_record RECORD;
    v_alert_message VARCHAR;
BEGIN
    FOR v_record IN
        SELECT ws.stock_id, w.warehouse_name, p.product_name, ws.quantity_on_hand
        FROM warehouse_stock ws
        JOIN warehouses w ON ws.warehouse_id = w.warehouse_id
        JOIN products p ON ws.product_id = p.product_id
        WHERE ws.quantity_on_hand < ws.reorder_level
    LOOP
        v_alert_message := 'ALERT: ' || v_record.product_name ||
                          ' at ' || v_record.warehouse_name ||
                          ' is below reorder level (qty: ' || v_record.quantity_on_hand || ')';
        RAISE NOTICE '%', v_alert_message;
    END LOOP;

    COMMIT;
END;
$procedure$;

-- Procedure to cleanup old audit logs (demonstrates temporal operations)
CREATE OR REPLACE PROCEDURE cleanup_old_audit_logs(
    p_days_to_keep INTEGER DEFAULT 90
) LANGUAGE plpgsql AS $procedure$
DECLARE
    v_deleted_count INTEGER;
BEGIN
    DELETE FROM audit_log
    WHERE changed_at < CURRENT_TIMESTAMP - (p_days_to_keep || ' days')::INTERVAL;

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % old audit log records', v_deleted_count;

    COMMIT;
END;
$procedure$;
