-- Oracle PL/SQL Accounts Schema (Supported)
CREATE TABLE accounts (
    account_id NUMBER PRIMARY KEY,
    account_name VARCHAR2(100) NOT NULL,
    balance NUMBER(15,2),
    created_date DATE DEFAULT SYSDATE
);

CREATE FUNCTION get_account_balance(p_account_id NUMBER)
RETURN NUMBER IS
    v_balance NUMBER;
BEGIN
    SELECT balance INTO v_balance FROM accounts WHERE account_id = p_account_id;
    RETURN NVL(v_balance, 0);
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 0;
END get_account_balance;
/
