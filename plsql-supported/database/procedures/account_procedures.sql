-- Oracle PL/SQL Stored Procedures for Account Management

-- Procedure to open new account
CREATE OR REPLACE PROCEDURE open_account (
    p_customer_id IN NUMBER,
    p_account_type IN VARCHAR2,
    p_initial_balance IN NUMBER,
    p_account_id OUT NUMBER,
    p_error_message OUT VARCHAR2
) IS
    v_account_number VARCHAR2(20);
    v_seq_value NUMBER;
BEGIN
    BEGIN
        -- Generate account number
        SELECT account_seq.NEXTVAL INTO v_seq_value FROM DUAL;
        v_account_number := 'ACC' || LPAD(v_seq_value, 10, '0');

        -- Insert account
        INSERT INTO accounts (
            account_id, account_number, customer_id, account_type,
            balance, opened_date, status
        ) VALUES (
            account_seq.CURRVAL, v_account_number, p_customer_id,
            p_account_type, p_initial_balance, SYSDATE, 'A'
        );

        p_account_id := account_seq.CURRVAL;

        -- Log to audit
        INSERT INTO audit_log (
            log_id, table_name, record_id, action, new_values, changed_by
        ) VALUES (
            audit_seq.NEXTVAL, 'accounts', p_account_id, 'INSERT',
            'Account opened with type: ' || p_account_type,
            USER
        );

        COMMIT;
        p_error_message := NULL;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_error_message := SQLERRM;
            RAISE_APPLICATION_ERROR(-20001, 'Error opening account: ' || SQLERRM);
    END;
END open_account;
/

-- Procedure to close account
CREATE OR REPLACE PROCEDURE close_account (
    p_account_id IN NUMBER,
    p_reason IN VARCHAR2
) IS
    v_balance NUMBER;
BEGIN
    BEGIN
        -- Check account balance
        SELECT balance INTO v_balance FROM accounts WHERE account_id = p_account_id;

        IF v_balance <> 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Cannot close account with non-zero balance');
        END IF;

        -- Update account status
        UPDATE accounts
        SET status = 'C', closed_date = SYSDATE, updated_date = SYSDATE
        WHERE account_id = p_account_id;

        -- Log closure
        INSERT INTO audit_log (
            log_id, table_name, record_id, action, new_values, changed_by
        ) VALUES (
            audit_seq.NEXTVAL, 'accounts', p_account_id, 'UPDATE',
            'Account closed: ' || p_reason,
            USER
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;
END close_account;
/

-- Procedure to post transaction
CREATE OR REPLACE PROCEDURE post_transaction (
    p_account_id IN NUMBER,
    p_transaction_type IN VARCHAR2,
    p_amount IN NUMBER,
    p_description IN VARCHAR2,
    p_transaction_id OUT NUMBER,
    p_error_message OUT VARCHAR2
) IS
    v_balance NUMBER;
    v_new_balance NUMBER;
BEGIN
    BEGIN
        -- Validate transaction
        IF NOT is_valid_transaction_amount(p_account_id, p_amount) THEN
            RAISE_APPLICATION_ERROR(-20003, 'Invalid transaction amount');
        END IF;

        -- Get current balance
        SELECT balance INTO v_balance FROM accounts WHERE account_id = p_account_id;

        -- Calculate new balance
        IF p_transaction_type = 'DEBIT' THEN
            v_new_balance := v_balance - p_amount;
        ELSE
            v_new_balance := v_balance + p_amount;
        END IF;

        -- Insert transaction
        SELECT transaction_seq.NEXTVAL INTO p_transaction_id FROM DUAL;
        INSERT INTO transactions (
            transaction_id, account_id, transaction_type, amount,
            transaction_date, balance_after, description
        ) VALUES (
            p_transaction_id, p_account_id, p_transaction_type, p_amount,
            SYSDATE, v_new_balance, p_description
        );

        -- Update account balance
        UPDATE accounts
        SET balance = v_new_balance, updated_date = SYSDATE
        WHERE account_id = p_account_id;

        COMMIT;
        p_error_message := NULL;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_error_message := SQLERRM;
    END;
END post_transaction;
/

-- Procedure to apply monthly fees
CREATE OR REPLACE PROCEDURE apply_monthly_fees IS
    CURSOR account_cursor IS
        SELECT account_id FROM accounts WHERE status = 'A';
    v_fee_amount NUMBER;
BEGIN
    FOR acc_rec IN account_cursor LOOP
        v_fee_amount := calculate_account_fees(acc_rec.account_id);

        IF v_fee_amount > 0 THEN
            UPDATE accounts
            SET balance = balance - v_fee_amount,
                updated_date = SYSDATE
            WHERE account_id = acc_rec.account_id;

            INSERT INTO transactions (
                transaction_id, account_id, transaction_type, amount,
                transaction_date, description
            ) VALUES (
                transaction_seq.NEXTVAL, acc_rec.account_id, 'FEE',
                v_fee_amount, SYSDATE, 'Monthly maintenance fee'
            );
        END IF;
    END LOOP;

    COMMIT;
END apply_monthly_fees;
/
