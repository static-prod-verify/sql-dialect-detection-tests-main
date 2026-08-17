-- Snowflake Stored Procedures for Analytics
-- Snowflake-specific procedure syntax

CREATE OR REPLACE PROCEDURE load_customer_analytics()
RETURNS OBJECT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('pandas', 'snowflake-snowpark-python')
AS $$
from snowflake.snowpark import Session
import pandas as pd

def main():
    session = Session.builder.getOrCreate()

    # Load customer data
    customers = session.table("CUSTOMERS")
    events = session.table("EVENTS")

    # Process analytics
    result = customers.join(events, "CUSTOMER_ID").group_by("CUSTOMER_ID").agg({"COUNT": "*"})

    return {"status": "complete", "rows_processed": result.count()}

return main()
$$;

CREATE OR REPLACE PROCEDURE generate_customer_report(
    p_customer_id NUMBER,
    p_report_date DATE
)
RETURNS VARCHAR
LANGUAGE SQL
AS
DECLARE
    result_status VARCHAR;
    total_events NUMBER;
BEGIN
    -- Get customer event count
    SELECT COUNT(*) INTO total_events
    FROM events
    WHERE customer_id = p_customer_id
    AND DATE(event_timestamp) = p_report_date;

    -- Insert into audit log
    INSERT INTO audit_log (table_name, record_id, action, changed_by)
    VALUES ('customers', p_customer_id, 'REPORT_GENERATED', CURRENT_USER());

    SET result_status = 'Report generated for customer ' || p_customer_id || ' with ' || total_events || ' events';

    RETURN result_status;
END;

CREATE OR REPLACE PROCEDURE process_staged_data(
    p_stage_path VARCHAR
)
RETURNS TABLE (status VARCHAR, file_name VARCHAR, record_count NUMBER)
LANGUAGE SQL
AS
BEGIN
    -- Read from Snowflake stage (Snowflake-specific)
    CREATE TEMPORARY TABLE staged_data AS
    SELECT $1 as raw_data FROM @analytics_stage/p_stage_path
    (FILE_FORMAT => 'json_format');

    -- Process data
    INSERT INTO customers
    SELECT
        raw_data:customer_id::NUMBER,
        raw_data:name::VARCHAR,
        raw_data,
        raw_data:email::VARCHAR
    FROM staged_data;

    -- Return status
    RETURN (
        SELECT 'Loaded' as status, 'data_file' as file_name, COUNT(*) as record_count
        FROM staged_data
    );
END;

CREATE OR REPLACE PROCEDURE backup_customer_data()
RETURNS VARCHAR
LANGUAGE SQL
AS
BEGIN
    -- Create backup using CLONE (Snowflake-specific feature)
    CREATE OR REPLACE TABLE customers_backup_latest CLONE customers;

    -- Update audit log
    INSERT INTO audit_log (table_name, action, changed_by)
    VALUES ('customers', 'BACKUP_CREATED', 'SYSTEM');

    RETURN 'Backup completed at ' || TO_VARCHAR(CURRENT_TIMESTAMP());
END;
