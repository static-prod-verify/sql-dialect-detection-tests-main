# Test Case: SQL Mixed with Other Source Languages

## Purpose

Test that valid SQL is packaged correctly even when mixed with Java, Python, and other non-SQL source code in the same project.

## Expected Behavior

1. **T-SQL files detected and packaged**
2. **Java source code also included**
3. **Python source code also included**
4. **No SQL warnings** (T-SQL is supported)
5. **All source types packaged together**

## Project Structure

```
sql-with-non-sql/
├── database/
│   └── transactions.sql    # T-SQL code
├── java-app/
│   └── Application.java    # Java code
├── src/
│   └── main.py            # Python code
├── .veracode/
│   ├── auto-package.sh
│   └── manual-package.sh
└── README.md
```

## Verification

- T-SQL detected and packaged
- Java and Python included
- No SQL warnings
- All file types in package
