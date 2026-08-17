# Test Case: T-SQL Supported (SQL Server)

## Purpose

Test that SQL Server T-SQL files are correctly identified as a SUPPORTED dialect and successfully packaged without warnings.

## Test Case Description

This project simulates a SQL Server database system using T-SQL:
- GO batch separators (T-SQL-specific)
- [Bracket] identifiers (T-SQL-specific)
- IDENTITY auto-increment (T-SQL-specific)
- CREATE PROCEDURE, CREATE FUNCTION (T-SQL syntax)
- SET statements (BEGIN TRAN, COMMIT TRAN)
- Should detect as T-SQL and proceed with packaging

## Project Structure

```
tsql-supported/
├── database/
│   ├── schema/
│   │   └── 01_tables.sql
│   ├── functions/
│   │   └── employee_functions.sql
│   ├── procedures/
│   │   └── employee_procedures.sql
│   └── stored-procedures/
│       └── hr_stored_procedures.sql
├── .veracode/
│   ├── auto-package.sh
│   └── manual-package.sh
└── README.md
```

## Expected Behavior

1. **Packager detects T-SQL dialect** - Should match T-SQL-specific patterns
2. **SQL detection returns TSQL** - Not GenericSQL
3. **NO warning is logged** - SQL is supported
4. **SQL files ARE packaged** - T-SQL is a supported dialect

## T-SQL Specific Features in Test Data

1. **GO batch separator** - T-SQL-specific (not in Oracle/PostgreSQL)
2. **[Bracket] identifiers** - T-SQL way of quoting names
3. **IDENTITY** - T-SQL auto-increment (different from MySQL AUTO_INCREMENT)
4. **SET QUOTED_IDENTIFIER** - T-SQL configuration statement
5. **BEGIN TRAN / COMMIT TRAN** - T-SQL transaction syntax
6. **CREATE PROCEDURE** - T-SQL stored procedure syntax
7. **NVARCHAR** - T-SQL Unicode string type

## SQL Files Summary

### schema/01_tables.sql
- T-SQL schema with [dbo] prefix
- IDENTITY primary keys
- NVARCHAR for Unicode strings
- DATETIME defaults
- Foreign key constraints

### functions/employee_functions.sql
- Scalar functions returning specific types
- T-SQL function syntax
- RETURNS clause (T-SQL-specific)

### procedures/employee_procedures.sql
- Stored procedures with T-SQL syntax
- @parameter variables (T-SQL-specific)
- Transaction control (T-SQL-specific)

### stored-procedures/hr_stored_procedures.sql
- Additional HR-related procedures
- Dynamic SQL examples (T-SQL style)

## Exit Code Expectations

- Exit code: **0** (success)
- Warning logged: NO (T-SQL is supported)
- SQL packaged: YES
- T-SQL detected: YES

## Notes

- This is a **positive test** - should pass without warnings
- Verifies T-SQL dialect is correctly recognized
- Confirms T-SQL SQL is packaged successfully
- Should NOT trigger "unsupported dialect" warning
