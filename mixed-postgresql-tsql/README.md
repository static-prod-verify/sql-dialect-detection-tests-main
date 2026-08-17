# Test Case: Mixed PostgreSQL + T-SQL

## Purpose

Test that projects containing both PostgreSQL (unsupported) and T-SQL (supported) SQL files are correctly handled: T-SQL packaged, PostgreSQL skipped, with appropriate warnings.

## Expected Behavior

1. **Packager detects BOTH dialects**
2. **T-SQL matches and is packaged** (supported)
3. **PostgreSQL detected but not packaged** (unsupported)
4. **Warning logged for PostgreSQL**: "SQL source code discovered in an unsupported dialect. Only PL/SQL and T-SQL are supported."
5. **Final package contains ONLY T-SQL**

## Project Structure

```
mixed-postgresql-tsql/
├── database/
│   ├── postgresql/          # PostgreSQL files (not packaged)
│   │   └── inventory.sql
│   └── tsql/               # T-SQL files (packaged)
│       └── orders.sql
├── .veracode/
│   ├── auto-package.sh
│   └── manual-package.sh
└── README.md
```

## Verification

- Should warn about PostgreSQL being unsupported
- Package should contain T-SQL files only
- No T-SQL warnings should be issued
- Final exit code: 0 (success)
