# Test Case: Empty SQL Files with Valid SQL

## Purpose

Test that empty SQL files don't interfere with dialect detection when mixed with valid SQL files.

## Expected Behavior

1. **Empty .sql files are ignored**
2. **Valid T-SQL files are detected and packaged**
3. **No errors from empty files**
4. **Package contains valid SQL only**

## Project Structure

```
empty-sql-files/
├── database/
│   ├── empty_file_1.sql    # Empty file
│   ├── empty_file_2.sql    # Empty file
│   └── valid_tsql.sql      # Valid T-SQL code
├── .veracode/
│   ├── auto-package.sh
│   └── manual-package.sh
└── README.md
```

## Verification

- Empty files should not cause errors
- Valid T-SQL should be detected
- Package should be created successfully
