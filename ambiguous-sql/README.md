# Test Case: Ambiguous SQL

## Purpose

Test SQL files with ambiguous content that falls below the 30-keyword detection threshold, resulting in Unknown/GenericSQL dialect detection.

## Expected Behavior

1. **Basic SQL content detected** (CREATE TABLE, INSERT, SELECT)
2. **Insufficient dialect-specific keywords** (below 30-keyword threshold)
3. **Detected as GenericSQL (Unknown)**
4. **Warning logged about unsupported dialect**
5. **SQL NOT packaged**

## Project Structure

```
ambiguous-sql/
├── database/
│   └── ambiguous.sql      # Basic SQL without dialect-specific keywords
├── .veracode/
│   ├── auto-package.sh
│   └── manual-package.sh
└── README.md
```

## Verification

- Basic SQL recognized
- No strong T-SQL or PL/SQL indicators
- Warning about unsupported dialect
- SQL not packaged
