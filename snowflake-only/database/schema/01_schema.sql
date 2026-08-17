-- Snowflake Analytics Schema
-- Demonstrates Snowflake-specific features

-- Create stage for data files (Snowflake-specific)
CREATE OR REPLACE STAGE analytics_stage
  URL = 's3://my-bucket/analytics/'
  CREDENTIALS = (AWS_KEY_ID = '...' AWS_SECRET_KEY = '...')
  FILE_FORMAT = (TYPE = 'CSV' FIELD_DELIMITER = ',');

-- Create file format (Snowflake-specific)
CREATE OR REPLACE FILE FORMAT json_format
  TYPE = 'JSON'
  COMPRESSION = 'GZIP';

-- Customers table with Snowflake data types
CREATE OR REPLACE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    customer_name VARCHAR NOT NULL,
    customer_data VARIANT,  -- Snowflake-specific VARIANT type for semi-structured data
    email VARCHAR UNIQUE,
    contact_info OBJECT,    -- Snowflake-specific OBJECT type
    registration_date TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    tags ARRAY               -- Snowflake-specific ARRAY type
);

-- Events table
CREATE OR REPLACE TABLE events (
    event_id NUMBER PRIMARY KEY,
    customer_id NUMBER NOT NULL,
    event_type VARCHAR,
    event_data VARIANT,     -- Semi-structured data storage
    event_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Analytics summary table
CREATE OR REPLACE TABLE analytics_summary (
    summary_id NUMBER PRIMARY KEY,
    customer_id NUMBER,
    metric_date DATE,
    metrics_data OBJECT,    -- Complex metrics as object
    calculated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Audit log table
CREATE OR REPLACE TABLE audit_log (
    log_id NUMBER PRIMARY KEY,
    table_name VARCHAR,
    record_id NUMBER,
    action VARCHAR,
    old_values VARIANT,
    new_values VARIANT,
    changed_by VARCHAR,
    changed_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Create cloned table (Snowflake-specific feature)
CREATE OR REPLACE TABLE customers_backup CLONE customers;

-- Create dynamic table (Snowflake-specific)
CREATE OR REPLACE DYNAMIC TABLE customer_metrics AS
    SELECT
        customer_id,
        COUNT(*) as total_events,
        MAX(event_timestamp) as last_event_date
    FROM events
    GROUP BY customer_id;
