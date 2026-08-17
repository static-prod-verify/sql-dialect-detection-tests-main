# Test Case: PL/SQL Supported (Oracle)

## Purpose

Test that Oracle PL/SQL files are correctly identified as a SUPPORTED dialect and successfully packaged without warnings.

## Test Case Description

This project simulates an Oracle database system using PL/SQL:
- CREATE PACKAGE (PL/SQL-specific)
- NUMBER data type (PL/SQL-specific)
- SYSDATE function (Oracle-specific)
- BEGIN/END blocks (PL/SQL-specific)
- CREATE TABLE without schemas (Oracle default)
- Should detect as PL/SQL and proceed with packaging

## Project Structure

```
plsql-supported/
├── database/
│   ├── schema/
│   │   └── 01_tables.sql
│   ├── functions/
│   │   └── account_functions.sql
│   ├── procedures/
│   │   └── account_procedures.sql
│   └── packages/
│       └── account_pkg.sql
├── .veracode/
│   ├── auto-package.sh
│   └── manual-package.sh
└── README.md
```

## Expected Behavior

1. **Packager detects PL/SQL dialect** - Should match PL/SQL-specific patterns
2. **SQL detection returns PLSQL** - Not GenericSQL
3. **NO warning is logged** - SQL is supported
4. **SQL files ARE packaged** - PL/SQL is a supported dialect

## PL/SQL Specific Features in Test Data

1. **CREATE PACKAGE** - PL/SQL package declarations (Oracle-specific)
2. **NUMBER** - Oracle's universal numeric type
3. **SYSDATE** - Oracle system date function
4. **BEGIN/END** - PL/SQL block structure
5. **CREATE FUNCTION/PROCEDURE** - Oracle PL/SQL syntax
6. **VARCHAR2** - Oracle's variable-length string type
7. **ROWTYPE** - PL/SQL record type reference

## SQL Files Summary

### schema/01_tables.sql
- PL/SQL schema with NUMBER and VARCHAR2 types
- SYSDATE default timestamps
- Foreign key constraints
- Sequence definitions (Oracle-specific)

### functions/account_functions.sql
- Oracle PL/SQL functions
- RETURN type declarations
- BEGIN/END blocks
- Exception handling (Oracle-specific)

### procedures/account_procedures.sql
- Oracle PL/SQL procedures
- Parameter modes (IN, OUT, IN OUT)
- Transaction control
- Oracle-specific exception handling

### packages/account_pkg.sql
- Oracle package specification
- Package body definitions
- Multiple procedures/functions in one package

## Exit Code Expectations

- Exit code: **0** (success)
- Warning logged: NO (PL/SQL is supported)
- SQL packaged: YES
- PL/SQL detected: YES

## Notes

- This is a **positive test** - should pass without warnings
- Verifies PL/SQL dialect is correctly recognized
- Confirms PL/SQL SQL is packaged successfully
- Should NOT trigger "unsupported dialect" warning
