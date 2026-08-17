-- Oracle PL/SQL Account Management Schema

-- Create sequences (Oracle-specific)
CREATE SEQUENCE account_seq START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE transaction_seq START WITH 10000 INCREMENT BY 1;
CREATE SEQUENCE audit_seq START WITH 1 INCREMENT BY 1;

-- Accounts table
CREATE TABLE accounts (
    account_id NUMBER PRIMARY KEY,
    account_number VARCHAR2(20) UNIQUE NOT NULL,
    customer_id NUMBER NOT NULL,
    account_type VARCHAR2(20),
    balance NUMBER(15,2),
    opened_date DATE DEFAULT SYSDATE,
    closed_date DATE,
    status CHAR(1) DEFAULT 'A',
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE
);

-- Customers table
CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    customer_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) UNIQUE,
    phone VARCHAR2(20),
    address VARCHAR2(255),
    city VARCHAR2(100),
    state VARCHAR2(50),
    zip_code VARCHAR2(10),
    registration_date DATE DEFAULT SYSDATE,
    status CHAR(1) DEFAULT 'A'
);

-- Transactions table
CREATE TABLE transactions (
    transaction_id NUMBER PRIMARY KEY,
    account_id NUMBER NOT NULL,
    transaction_type VARCHAR2(20),
    amount NUMBER(15,2),
    transaction_date DATE DEFAULT SYSDATE,
    balance_after NUMBER(15,2),
    description VARCHAR2(255),
    reference_number VARCHAR2(50),
    CONSTRAINT fk_trans_account FOREIGN KEY (account_id)
        REFERENCES accounts(account_id)
);

-- Account Holders table
CREATE TABLE account_holders (
    holder_id NUMBER PRIMARY KEY,
    account_id NUMBER NOT NULL,
    holder_name VARCHAR2(100),
    holder_type VARCHAR2(20),
    percentage_ownership NUMBER(5,2),
    CONSTRAINT fk_holders_account FOREIGN KEY (account_id)
        REFERENCES accounts(account_id) ON DELETE CASCADE
);

-- Audit Log table
CREATE TABLE audit_log (
    log_id NUMBER PRIMARY KEY,
    table_name VARCHAR2(100),
    record_id NUMBER,
    action VARCHAR2(10),
    old_values VARCHAR2(4000),
    new_values VARCHAR2(4000),
    changed_by VARCHAR2(100),
    changed_date DATE DEFAULT SYSDATE
);

-- Fee Schedule table
CREATE TABLE fee_schedule (
    fee_id NUMBER PRIMARY KEY,
    account_type VARCHAR2(20),
    fee_type VARCHAR2(50),
    fee_amount NUMBER(10,2),
    effective_date DATE DEFAULT SYSDATE,
    end_date DATE
);

-- Create indexes
CREATE INDEX idx_accounts_customer ON accounts(customer_id);
CREATE INDEX idx_accounts_status ON accounts(status);
CREATE INDEX idx_transactions_account ON transactions(account_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_customers_status ON customers(status);
CREATE INDEX idx_audit_table_record ON audit_log(table_name, record_id);

-- Create unique constraint
ALTER TABLE accounts ADD CONSTRAINT uk_account_number UNIQUE (account_number);
