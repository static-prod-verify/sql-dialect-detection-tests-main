-- Oracle PL/SQL User-Defined Functions for Account Management

-- Function to calculate account fees
CREATE OR REPLACE FUNCTION calculate_account_fees (
    p_account_id IN NUMBER
) RETURN NUMBER IS
    v_total_fees NUMBER := 0;
    v_account_type VARCHAR2(20);
    CURSOR fee_cursor IS
        SELECT fee_amount FROM fee_schedule
        WHERE account_type = v_account_type
        AND SYSDATE BETWEEN effective_date AND NVL(end_date, SYSDATE);
BEGIN
    SELECT account_type INTO v_account_type
    FROM accounts
    WHERE account_id = p_account_id;

    FOR fee_rec IN fee_cursor LOOP
        v_total_fees := v_total_fees + fee_rec.fee_amount;
    END LOOP;

    RETURN v_total_fees;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END calculate_account_fees;
/

-- Function to check account balance
CREATE OR REPLACE FUNCTION get_account_balance (
    p_account_id IN NUMBER
) RETURN NUMBER IS
    v_balance NUMBER;
BEGIN
    SELECT balance INTO v_balance
    FROM accounts
    WHERE account_id = p_account_id
    AND status = 'A';

    RETURN NVL(v_balance, 0);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Account not found');
END get_account_balance;
/

-- Function to validate transaction amount
CREATE OR REPLACE FUNCTION is_valid_transaction_amount (
    p_account_id IN NUMBER,
    p_amount IN NUMBER
) RETURN BOOLEAN IS
    v_balance NUMBER;
    v_max_transaction NUMBER := 10000;
BEGIN
    v_balance := get_account_balance(p_account_id);

    IF p_amount <= 0 THEN
        RETURN FALSE;
    END IF;

    IF p_amount > v_max_transaction THEN
        RETURN FALSE;
    END IF;

    IF p_amount > v_balance THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END is_valid_transaction_amount;
/

-- Function to get customer name - vulnerable to SQL injection for testing
CREATE OR REPLACE FUNCTION get_customer_name (
    p_customer_id IN NUMBER
) RETURN VARCHAR2 IS
    v_name VARCHAR2(100);
    v_sql VARCHAR2(500);
BEGIN
    v_sql := 'SELECT customer_name FROM customers WHERE customer_id = ' || p_customer_id;
    EXECUTE IMMEDIATE v_sql INTO v_name;
    RETURN NVL(v_name, 'Unknown');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END get_customer_name;
/

-- Function to get transaction count for account
CREATE OR REPLACE FUNCTION get_transaction_count (
    p_account_id IN NUMBER
) RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM transactions
    WHERE account_id = p_account_id
    AND TRUNC(transaction_date) = TRUNC(SYSDATE);

    RETURN v_count;
END get_transaction_count;
/
