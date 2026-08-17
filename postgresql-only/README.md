# Test Case: PostgreSQL Only (Unsupported Dialect)

## Purpose

Test that PostgreSQL SQL files are correctly identified as an unsupported dialect and trigger the appropriate warning message without being packaged.

## Test Case Description

This project simulates a pure PostgreSQL database system using PL/pgSQL:
- PostgreSQL-specific extensions (uuid-ossp, pgcrypto)
- Enum data types (PostgreSQL feature)
- PL/pgSQL functions and procedures
- CASCADE deletes (PostgreSQL-specific)
- Should NOT match T-SQL or PL/SQL keywords

## Project Structure

```
postgresql-only/
├── database/
│   ├── schema/
│   │   └── 01_schema.sql           # PostgreSQL schema with enums
│   ├── functions/
│   │   └── inventory_functions.sql # PL/pgSQL functions
│   ├── procedures/
│   │   └── inventory_procedures.sql # PL/pgSQL procedures
├── .veracode/
│   ├── auto-package.sh
│   └── manual-package.sh
└── README.md
```

## Expected Behavior

1. **Packager detects PostgreSQL dialect** - Should NOT match T-SQL or PL/SQL patterns
2. **SQL detection returns Unknown** - Mapped to GenericSQL in discovery
3. **Warning is logged**: "[WARN] SQL source code discovered in an unsupported dialect. Only PL/SQL and T-SQL are supported. Skipping SQL packaging."
4. **SQL files are NOT packaged** - Only GenericSQL detected, not supported

## Verification Steps

### Step 1: Run the Packager
```bash
cd /Users/rlayzell/dev/static/packager/static-packager-repos/sql/postgresql-only
bash .veracode/auto-package.sh 2>&1 | tee packaging.log
```

### Step 2: Check for Expected Warning
```bash
grep -i "unsupported dialect" packaging.log
grep -i "only.*pl.*sql.*t-sql.*supported" packaging.log
```

Expected output:
```
[WARN] SQL source code discovered in an unsupported dialect. Only PL/SQL and T-SQL are supported. Skipping SQL packaging.
```

### Step 3: Verify SQL NOT Packaged
```bash
grep -E "GenericSQL|postgres|pgsql" packaging.log
```

Expected: Should NOT see T-SQL or PL/SQL, should see GenericSQL

### Step 4: Verify Package (or lack thereof)
```bash
ls -la .veracode/output/
```

Expected: Package exists but should NOT contain .sql files or contain them only as non-scanned

## PostgreSQL Specific Features in Test Data

1. **Extensions** - uuid-ossp, pgcrypto (PostgreSQL-specific)
2. **Enum types** - CREATE TYPE ... AS ENUM (PostgreSQL 8.3+)
3. **CASCADE syntax** - DROP TABLE ... CASCADE (different from Oracle)
4. **PL/pgSQL** - LANGUAGE plpgsql, $function$ syntax
5. **PostgreSQL keywords** - EXTENSION, ENUM, CASCADE

These features ensure the SQL detector does NOT confuse PostgreSQL with T-SQL or PL/SQL.

## SQL Files Summary

### schema/01_schema.sql
- PostgreSQL extensions (uuid-ossp, pgcrypto)
- Enum types for product_status, warehouse_type, audit_action
- Table definitions with UUID primary keys
- CASCADE drop syntax

### functions/inventory_functions.sql
- PL/pgSQL function definitions
- $function$ delimiters (PostgreSQL-specific)
- LANGUAGE plpgsql declarations
- RETURN types for functions

### procedures/inventory_procedures.sql
- PL/pgSQL stored procedures
- Parameter handling (PostgreSQL way)
- Dynamic SQL with EXECUTE

## Exit Code Expectations

- Exit code: **0** (success - packager runs)
- Warning logged: YES
- SQL packaged: NO
- GenericSQL detected: YES

## Notes

- This tests the **simplification** of removing PostgreSQL-specific detection
- PostgreSQL SQL should still result in Unknown dialect
- Warning message must be clear about what IS supported (T-SQL, PL/SQL)
- No .sql files should be included in the final package
