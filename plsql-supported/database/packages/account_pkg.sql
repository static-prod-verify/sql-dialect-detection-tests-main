-- Oracle PL/SQL Package for Account Management
-- Package specification and body (combined)

-- Package Specification
CREATE OR REPLACE PACKAGE account_pkg IS
    -- Public procedures
    PROCEDURE initialize_account (
        p_customer_id IN NUMBER,
        p_account_type IN VARCHAR2,
        p_account_id OUT NUMBER
    );

    PROCEDURE transfer_funds (
        p_from_account IN NUMBER,
        p_to_account IN NUMBER,
        p_amount IN NUMBER
    );

    -- Public functions
    FUNCTION get_account_status (p_account_id IN NUMBER) RETURN VARCHAR2;
    FUNCTION validate_account (p_account_id IN NUMBER) RETURN BOOLEAN;

END account_pkg;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY account_pkg IS

    -- Private procedure for logging
    PROCEDURE log_action (
        p_action IN VARCHAR2,
        p_details IN VARCHAR2
    ) IS
    BEGIN
        INSERT INTO audit_log (
            log_id, table_name, action, new_values, changed_by
        ) VALUES (
            audit_seq.NEXTVAL, 'account_pkg', p_action, p_details, USER
        );
    END log_action;

    -- Public procedure implementation
    PROCEDURE initialize_account (
        p_customer_id IN NUMBER,
        p_account_type IN VARCHAR2,
        p_account_id OUT NUMBER
    ) IS
        v_account_number VARCHAR2(20);
    BEGIN
        SELECT account_seq.NEXTVAL INTO p_account_id FROM DUAL;
        v_account_number := 'ACC' || LPAD(p_account_id, 10, '0');

        INSERT INTO accounts (
            account_id, account_number, customer_id, account_type,
            balance, opened_date, status
        ) VALUES (
            p_account_id, v_account_number, p_customer_id,
            p_account_type, 0, SYSDATE, 'A'
        );

        log_action('INITIALIZE', 'Account ' || v_account_number || ' created');
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            log_action('ERROR', 'Initialize failed: ' || SQLERRM);
            RAISE;
    END initialize_account;

    -- Public procedure for fund transfers
    PROCEDURE transfer_funds (
        p_from_account IN NUMBER,
        p_to_account IN NUMBER,
        p_amount IN NUMBER
    ) IS
        v_from_balance NUMBER;
        v_to_balance NUMBER;
    BEGIN
        -- Lock rows for update
        SELECT balance INTO v_from_balance FROM accounts
        WHERE account_id = p_from_account FOR UPDATE;

        SELECT balance INTO v_to_balance FROM accounts
        WHERE account_id = p_to_account FOR UPDATE;

        IF v_from_balance < p_amount THEN
            RAISE_APPLICATION_ERROR(-20004, 'Insufficient funds');
        END IF;

        -- Debit source account
        UPDATE accounts SET balance = balance - p_amount
        WHERE account_id = p_from_account;

        -- Credit destination account
        UPDATE accounts SET balance = balance + p_amount
        WHERE account_id = p_to_account;

        -- Log transactions
        INSERT INTO transactions (
            transaction_id, account_id, transaction_type, amount, description
        ) VALUES (
            transaction_seq.NEXTVAL, p_from_account, 'TRANSFER_OUT', p_amount,
            'Transfer to account ' || p_to_account
        );

        INSERT INTO transactions (
            transaction_id, account_id, transaction_type, amount, description
        ) VALUES (
            transaction_seq.NEXTVAL, p_to_account, 'TRANSFER_IN', p_amount,
            'Transfer from account ' || p_from_account
        );

        log_action('TRANSFER', 'Transfer of ' || p_amount || ' completed');
        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            log_action('ERROR', 'Transfer failed: ' || SQLERRM);
            RAISE;
    END transfer_funds;

    -- Public function to get account status
    FUNCTION get_account_status (p_account_id IN NUMBER) RETURN VARCHAR2 IS
        v_status CHAR(1);
    BEGIN
        SELECT status INTO v_status FROM accounts
        WHERE account_id = p_account_id;

        CASE v_status
            WHEN 'A' THEN RETURN 'Active';
            WHEN 'C' THEN RETURN 'Closed';
            WHEN 'F' THEN RETURN 'Frozen';
            ELSE RETURN 'Unknown';
        END CASE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Not Found';
    END get_account_status;

    -- Public function to validate account
    FUNCTION validate_account (p_account_id IN NUMBER) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM accounts
        WHERE account_id = p_account_id AND status = 'A';

        RETURN v_count > 0;
    END validate_account;

END account_pkg;
/
