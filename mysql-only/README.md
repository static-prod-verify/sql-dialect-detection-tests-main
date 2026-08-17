# Test Case: MySQL Only (Unsupported Dialect)

## Purpose

Test that MySQL SQL files are correctly identified as an unsupported dialect and trigger the appropriate warning message without being packaged.

## Test Case Description

This project simulates a MySQL database system using MySQL-specific syntax:
- Engine specifications (ENGINE=InnoDB)
- Backtick-quoted identifiers (MySQL-specific)
- DELIMITER statements (MySQL procedure syntax)
- MySQL-specific keywords and functions
- Should NOT match T-SQL or PL/SQL keywords

## Project Structure

```
mysql-only/
├── database/
│   ├── schema/
│   │   └── 01_schema.sql            # MySQL schema with InnoDB
│   ├── functions/
│   │   └── order_functions.sql      # MySQL functions
│   ├── procedures/
│   │   └── order_procedures.sql     # MySQL procedures
├── .veracode/
│   ├── auto-package.sh
│   └── manual-package.sh
└── README.md
```

## Expected Behavior

1. **Packager detects MySQL dialect** - Should NOT match T-SQL or PL/SQL patterns
2. **SQL detection returns Unknown** - Mapped to GenericSQL in discovery
3. **Warning is logged**: "[WARN] SQL source code discovered in an unsupported dialect. Only PL/SQL and T-SQL are supported. Skipping SQL packaging."
4. **SQL files are NOT packaged** - Only GenericSQL detected, not supported

## Verification Steps

### Step 1: Run the Packager
```bash
cd /Users/rlayzell/dev/static/packager/static-packager-repos/sql/mysql-only
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
grep -E "GenericSQL|mysql" packaging.log
```

Expected: Should NOT see T-SQL or PL/SQL, should see GenericSQL

## MySQL Specific Features in Test Data

1. **Engine specifications** - ENGINE=InnoDB, ENGINE=MyISAM (MySQL-specific)
2. **Backtick identifiers** - `table_name`, `column_name` (MySQL-specific)
3. **DELIMITER statements** - Used for procedure definitions (MySQL-specific)
4. **MySQL functions** - DATE_FORMAT, CONCAT, SUBSTRING (MySQL-specific)
5. **AUTO_INCREMENT** - Different from SQL Server IDENTITY

These features ensure the SQL detector does NOT confuse MySQL with T-SQL or PL/SQL.

## SQL Files Summary

### schema/01_schema.sql
- InnoDB engine specifications
- Backtick-quoted table and column identifiers
- MySQL-specific data types (MEDIUMINT, BIGINT)
- Foreign key constraints
- AUTO_INCREMENT primary keys

### functions/order_functions.sql
- MySQL function definitions
- RETURNS and DETERMINISTIC keywords
- MySQL-specific string functions
- DELIMITER statements

### procedures/order_procedures.sql
- MySQL stored procedure definitions
- Parameter handling (MySQL way)
- DELIMITER statements for multi-statement procedures
- Dynamic SQL with PREPARE/EXECUTE

## Exit Code Expectations

- Exit code: **0** (success - packager runs)
- Warning logged: YES
- SQL packaged: NO
- GenericSQL detected: YES

## Notes

- Tests MySQL dialect detection and exclusion
- MySQL SQL should result in Unknown dialect
- Warning message must be clear about what IS supported (T-SQL, PL/SQL)
- No .sql files should be included in the final package
