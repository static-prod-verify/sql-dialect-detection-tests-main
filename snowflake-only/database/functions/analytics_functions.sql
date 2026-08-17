-- Snowflake User-Defined Functions for Analytics
-- Snowflake-specific function syntax

CREATE OR REPLACE FUNCTION calculate_customer_score(
    p_total_events NUMBER,
    p_total_spend NUMBER
)
RETURNS NUMBER
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
AS $$
def calculate_score(events, spend):
    # Simple scoring algorithm
    event_weight = events * 0.5
    spend_weight = spend * 0.3
    return event_weight + spend_weight

return calculate_score(p_total_events, p_total_spend)
$$;

CREATE OR REPLACE FUNCTION parse_json_field(
    p_json_data VARIANT,
    p_field_path VARCHAR
)
RETURNS VARCHAR
LANGUAGE SQL
AS $$
  GET_PATH(p_json_data, PARSE_JSON('"' || p_field_path || '"'))
$$;

CREATE OR REPLACE FUNCTION get_account_info()
RETURNS VARCHAR
LANGUAGE SQL
AS $$
  SELECT CONCAT('Account: ', CURRENT_ACCOUNT(), ' Database: ', CURRENT_DATABASE(), ' User: ', CURRENT_USER())
$$;

CREATE OR REPLACE FUNCTION validate_customer_data(
    p_customer_data VARIANT
)
RETURNS BOOLEAN
LANGUAGE JAVASCRIPT
AS $$
function validateData(data) {
    if (!data.customer_id) return false;
    if (!data.email) return false;
    return true;
}
return validateData(JSON.parse(P_CUSTOMER_DATA));
$$;
