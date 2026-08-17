# Test Case: Mixed MySQL + PL/SQL

## Purpose

Test that projects containing both MySQL (unsupported) and PL/SQL (supported) SQL files are correctly handled: PL/SQL packaged, MySQL skipped, with appropriate warnings.

## Expected Behavior

1. **Packager detects BOTH dialects**
2. **PL/SQL matches and is packaged** (supported)
3. **MySQL detected but not packaged** (unsupported)
4. **Warning logged for MySQL**: "SQL source code discovered in an unsupported dialect. Only PL/SQL and T-SQL are supported."
5. **Final package contains ONLY PL/SQL**

## Project Structure

```
mixed-mysql-plsql/
├── database/
│   ├── mysql/              # MySQL files (not packaged)
│   │   └── customers.sql
│   └── plsql/             # PL/SQL files (packaged)
│       └── accounts.sql
├── .veracode/
│   ├── auto-package.sh
│   └── manual-package.sh
└── README.md
```

## Verification

- Should warn about MySQL being unsupported
- Package should contain PL/SQL files only
- No PL/SQL warnings should be issued
- Final exit code: 0 (success)
