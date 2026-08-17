# Test Case: Snowflake Only (Unsupported Dialect)

## Purpose

Test that Snowflake SQL files are correctly identified as an unsupported dialect and trigger the appropriate warning message without being packaged.

## Test Case Description

This project simulates a Snowflake data warehouse system using Snowflake-specific syntax:
- CREATE OR REPLACE statements (Snowflake version-agnostic approach)
- Snowflake stages and file formats
- CLONE operations (Snowflake-specific)
- Snowflake-specific functions (CURRENT_TIMESTAMP, CURRENT_ACCOUNT)
- Snowflake data types (VARIANT, ARRAY, OBJECT)
- Should NOT match T-SQL or PL/SQL keywords

## Project Structure

```
snowflake-only/
├── database/
│   ├── schema/
│   │   └── 01_schema.sql            # Snowflake schema
│   ├── functions/
│   │   └── analytics_functions.sql  # Snowflake functions
│   ├── procedures/
│   │   └── analytics_procedures.sql # Snowflake procedures
├── .veracode/
│   ├── auto-package.sh
│   └── manual-package.sh
└── README.md
```

## Expected Behavior

1. **Packager detects Snowflake dialect** - Should NOT match T-SQL or PL/SQL patterns
2. **SQL detection returns Unknown** - Mapped to GenericSQL in discovery
3. **Warning is logged**: "[WARN] SQL source code discovered in an unsupported dialect. Only PL/SQL and T-SQL are supported. Skipping SQL packaging."
4. **SQL files are NOT packaged** - Only GenericSQL detected, not supported

## Snowflake Specific Features in Test Data

1. **CREATE OR REPLACE** - Snowflake's version-safe approach (different from T-SQL/PL/SQL)
2. **Stages** - CREATE STAGE for file management (Snowflake-specific)
3. **CLONE** - Time-travel and cloning (Snowflake-specific)
4. **Data types** - VARIANT, ARRAY, OBJECT, GEOGRAPHY (Snowflake-specific)
5. **Snowflake functions** - CURRENT_ACCOUNT, CURRENT_DATABASE, GET_QUERY_OPERATOR

These features ensure the SQL detector does NOT confuse Snowflake with T-SQL or PL/SQL.

## Exit Code Expectations

- Exit code: **0** (success - packager runs)
- Warning logged: YES
- SQL packaged: NO
- GenericSQL detected: YES

## Notes

- Tests Snowflake dialect detection and exclusion
- Snowflake SQL should result in Unknown dialect
- Warning message must be clear about what IS supported (T-SQL, PL/SQL)
- No .sql files should be included in the final package
