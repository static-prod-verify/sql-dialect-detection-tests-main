# Test Case: SQL Code in Non-.sql Extensions

## Purpose

Test that SQL code in non-.sql file extensions (like .txt, .bak, .sql.old) is NOT processed by the SQL detector, but valid .sql files are packaged.

## Expected Behavior

1. **.txt files ignored** (even if containing SQL)
2. **.sql.bak files ignored** (backup extension)
3. **.sql.old files ignored** (old extension)
4. **.sql files processed** (standard extension)
5. **Only .sql files packaged**

## Project Structure

```
no-sql-extension/
├── database/
│   ├── schema.sql           # Processed: T-SQL
│   ├── schema.sql.bak       # Ignored: backup file
│   ├── schema.sql.old       # Ignored: old file
│   └── procedures.txt       # Ignored: text file
├── .veracode/
│   ├── auto-package.sh
│   └── manual-package.sh
└── README.md
```

## Verification

- .sql files detected and packaged
- Other extensions ignored
- Package contains only .sql files
