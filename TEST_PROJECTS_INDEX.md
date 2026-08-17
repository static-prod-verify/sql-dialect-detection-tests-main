# SQL Dialect Test Projects Index

Comprehensive test suite for validating the ENG-70110 SQL detection fix across all scenarios.

## Overview

**Total Test Projects:** 12  
**Total Files:** 79  
**Location:** `/Users/rlayzell/dev/static/packager/static-packager-repos/sql/`

---

## Phase 1: Non-SQL Only (1 project)

### ✅ non-sql-only/ (14 files)

**Purpose:** Verify that non-SQL projects are NOT blocked by SQL detection

**Structure:**

- Java Spring Boot REST API (no SQL files)
- TypeScript React frontend
- Full application code with pom.xml

**Expected Result:**

- ✓ Package created successfully
- ✓ No SQL-related warnings
- ✓ Non-SQL code packaged normally

**Files:**

- `java-app/src/main/java/com/example/` - Java classes (Application, User, UserRepository, UserController)
- `frontend/src/` - TypeScript components (App.tsx, UserService.ts, index.tsx)
- `java-app/pom.xml`, `frontend/package.json`
- `.veracode/auto-package.sh`, `manual-package.sh`

---

## Phase 2: Unsupported Dialects (3 projects)

### ✅ postgresql-only/ (6 files)

**Purpose:** Test PostgreSQL dialect detection and exclusion

**Dialect Markers:**

- EXTENSION directives (uuid-ossp, pgcrypto)
- ENUM types (PostgreSQL-specific)
- `$function$` delimiters (PL/pgSQL)
- CASCADE DROP syntax
- LANGUAGE plpgsql

**Expected Result:**

- ✓ PostgreSQL detected as Unknown (GenericSQL)
- ✓ Warning: "SQL source code discovered in an unsupported dialect. Only PL/SQL and T-SQL are supported."
- ✓ SQL NOT packaged

**Files:**

- `database/schema/01_schema.sql` - PostgreSQL schema with extensions, enums, cascades
- `database/functions/inventory_functions.sql` - PL/pgSQL functions
- `database/procedures/inventory_procedures.sql` - PL/pgSQL procedures

---

### ✅ mysql-only/ (6 files)

**Purpose:** Test MySQL dialect detection and exclusion

**Dialect Markers:**

- ENGINE=InnoDB specifications
- Backtick identifiers `` `column_name` ``
- DELIMITER statements (MySQL-specific)
- AUTO_INCREMENT keyword
- MySQL-specific functions (DATE_FORMAT, CONCAT)

**Expected Result:**

- ✓ MySQL detected as Unknown (GenericSQL)
- ✓ Warning: "SQL source code discovered in an unsupported dialect..."
- ✓ SQL NOT packaged

**Files:**

- `database/schema/01_schema.sql` - MySQL tables with InnoDB engine
- `database/functions/order_functions.sql` - MySQL functions with DELIMITER
- `database/procedures/order_procedures.sql` - MySQL procedures

---

### ✅ snowflake-only/ (6 files)

**Purpose:** Test Snowflake dialect detection and exclusion

**Dialect Markers:**

- CREATE OR REPLACE statements
- VARIANT, ARRAY, OBJECT data types (Snowflake-specific)
- CLONE operations (time-travel)
- STAGE for file management
- CURRENT_ACCOUNT, CURRENT_DATABASE functions

**Expected Result:**

- ✓ Snowflake detected as Unknown (GenericSQL)
- ✓ Warning: "SQL source code discovered in an unsupported dialect..."
- ✓ SQL NOT packaged

**Files:**

- `database/schema/01_schema.sql` - Snowflake schema with stages, VARIANT types, CLONE
- `database/functions/analytics_functions.sql` - Python/JavaScript UDFs
- `database/procedures/analytics_procedures.sql` - Snowflake procedures with CLONE

---

## Phase 3: Supported Dialects (2 projects)

### ✅ tsql-supported/ (7 files)

**Purpose:** Verify T-SQL is detected and packaged correctly

**Dialect Markers:**

- GO batch separator (T-SQL-specific)
- [Bracket] identifiers
- IDENTITY auto-increment
- SET QUOTED_IDENTIFIER ON
- BEGIN TRAN / COMMIT TRAN
- NVARCHAR Unicode strings

**Expected Result:**

- ✓ T-SQL detected correctly
- ✓ NO warnings (supported dialect)
- ✓ SQL packaged successfully

**Files:**

- `database/schema/01_tables.sql` - T-SQL schema with IDENTITY, GO separators
- `database/functions/employee_functions.sql` - T-SQL functions
- `database/procedures/employee_procedures.sql` - T-SQL procedures
- `database/stored-procedures/hr_stored_procedures.sql` - HR procedures

---

### ✅ plsql-supported/ (7 files)

**Purpose:** Verify PL/SQL is detected and packaged correctly

**Dialect Markers:**

- CREATE PACKAGE (Oracle-specific)
- NUMBER data type (Oracle)
- SYSDATE function (Oracle)
- BEGIN/END blocks (PL/SQL)
- VARCHAR2 type
- CREATE SEQUENCE (Oracle)

**Expected Result:**

- ✓ PL/SQL detected correctly
- ✓ NO warnings (supported dialect)
- ✓ SQL packaged successfully

**Files:**

- `database/schema/01_tables.sql` - Oracle schema with NUMBER, SYSDATE, sequences
- `database/functions/account_functions.sql` - PL/SQL functions
- `database/procedures/account_procedures.sql` - PL/SQL procedures
- `database/packages/account_pkg.sql` - Oracle package specification and body

---

## Phase 4: Mixed Dialects (2 projects)

### ✅ mixed-postgresql-tsql/ (5 files)

**Purpose:** Test partial support with both unsupported and supported SQL

**Directory Structure:**

- `database/postgresql/` - PostgreSQL SQL (unsupported)
- `database/tsql/` - T-SQL SQL (supported)

**Expected Result:**

- ✓ T-SQL packaged
- ✓ PostgreSQL skipped
- ✓ Warning about PostgreSQL unsupported dialect
- ✓ Package contains T-SQL only

**Files:**

- `database/postgresql/inventory.sql` - PostgreSQL with EXTENSION, ENUM
- `database/tsql/orders.sql` - T-SQL with GO, IDENTITY

---

### ✅ mixed-mysql-plsql/ (5 files)

**Purpose:** Test partial support with both unsupported and supported SQL

**Directory Structure:**

- `database/mysql/` - MySQL SQL (unsupported)
- `database/plsql/` - PL/SQL SQL (supported)

**Expected Result:**

- ✓ PL/SQL packaged
- ✓ MySQL skipped
- ✓ Warning about MySQL unsupported dialect
- ✓ Package contains PL/SQL only

**Files:**

- `database/mysql/customers.sql` - MySQL with ENGINE=InnoDB, backticks
- `database/plsql/accounts.sql` - PL/SQL with NUMBER, SYSDATE

---

## Phase 5: Edge Cases (4 projects)

### ✅ empty-sql-files/ (6 files)

**Purpose:** Test robustness with empty SQL files mixed with valid SQL

**Test Case:**

- Empty .sql files (no content)
- Valid T-SQL files (with keywords)

**Expected Result:**

- ✓ Empty files ignored
- ✓ T-SQL detected in valid files
- ✓ No errors from empty files
- ✓ Package created successfully

**Files:**

- `database/empty_file_1.sql` - Empty file
- `database/empty_file_2.sql` - Empty file
- `database/valid_tsql.sql` - T-SQL with GO, IDENTITY, function

---

### ✅ ambiguous-sql/ (4 files)

**Purpose:** Test SQL below 30-keyword detection threshold

**Test Case:**

- Basic portable SQL (CREATE TABLE, SELECT, INSERT)
- No strong T-SQL or PL/SQL indicators
- Below keyword threshold

**Expected Result:**

- ✓ Detected as GenericSQL (Unknown)
- ✓ Warning about unsupported dialect
- ✓ SQL NOT packaged

**Files:**

- `database/ambiguous.sql` - Basic portable SQL (CREATE TABLE, INSERT, SELECT, VIEW, UPDATE, DELETE, INDEX)

---

### ✅ sql-with-non-sql/ (6 files)

**Purpose:** Test SQL packaged with Java, Python, and other languages

**Test Case:**

- T-SQL SQL code
- Java source code
- Python source code
- All in same project

**Expected Result:**

- ✓ T-SQL detected and packaged
- ✓ Java source included
- ✓ Python source included
- ✓ All file types in package

**Files:**

- `database/transactions.sql` - T-SQL with GO, IDENTITY
- `java-app/Application.java` - Java code
- `src/main.py` - Python code

---

### ✅ no-sql-extension/ (7 files)

**Purpose:** Test that only .sql files are processed

**Test Case:**

- `.sql` files (processed)
- `.sql.bak` files (ignored)
- `.sql.old` files (ignored)
- `.txt` files (ignored)

**Expected Result:**

- ✓ Only .sql files detected
- ✓ Backup/old/text files ignored
- ✓ T-SQL from .sql detected and packaged
- ✓ Other extensions not processed

**Files:**

- `database/schema.sql` - T-SQL (processed)
- `database/schema.sql.bak` - T-SQL backup (ignored)
- `database/schema.sql.old` - T-SQL old version (ignored)
- `database/procedures.txt` - SQL in text file (ignored)

---

## Test Execution Guide

### Running Individual Test Projects

Each project has packaging scripts:

```bash
cd /Users/rlayzell/dev/static/packager/static-packager-repos/sql/<project-name>

# Auto-package (quick)
bash .veracode/auto-package.sh

# Manual-package (step-by-step)
bash .veracode/manual-package.sh
```

### Expected Behavior Matrix

| Project | SQL Found | Dialect | Action | Warning | Package |
|---------|-----------|---------|--------|---------|---------|
| non-sql-only | NO | N/A | Package normally | NO | ✓ |
| postgresql-only | YES | PostgreSQL | Skip SQL | YES | ✗ SQL |
| mysql-only | YES | MySQL | Skip SQL | YES | ✗ SQL |
| snowflake-only | YES | Snowflake | Skip SQL | YES | ✗ SQL |
| tsql-supported | YES | T-SQL | Package SQL | NO | ✓ SQL |
| plsql-supported | YES | PL/SQL | Package SQL | NO | ✓ SQL |
| mixed-postgresql-tsql | YES | Mixed | Partial | YES (PG) | ✓ T-SQL |
| mixed-mysql-plsql | YES | Mixed | Partial | YES (MySQL) | ✓ PL/SQL |
| empty-sql-files | YES | T-SQL | Package SQL | NO | ✓ SQL |
| ambiguous-sql | YES | Unknown | Skip SQL | YES | ✗ SQL |
| sql-with-non-sql | YES | T-SQL | Package all | NO | ✓ All |
| no-sql-extension | YES | T-SQL | Package .sql | NO | ✓ .sql only |

---

## Validation Checklist

### Before ENG-70110 Implementation

Run all tests to establish baseline behavior with current code

### After ENG-70110 Implementation

Run all tests to verify fixes:

- [ ] non-sql-only: No SQL warnings
- [ ] postgresql-only: Correct unsupported warning
- [ ] mysql-only: Correct unsupported warning
- [ ] snowflake-only: Correct unsupported warning
- [ ] tsql-supported: No warnings, packaged
- [ ] plsql-supported: No warnings, packaged
- [ ] mixed-postgresql-tsql: Correct warnings, T-SQL packaged
- [ ] mixed-mysql-plsql: Correct warnings, PL/SQL packaged
- [ ] empty-sql-files: Valid SQL detected despite empty files
- [ ] ambiguous-sql: Correct unsupported warning
- [ ] sql-with-non-sql: All source types packaged
- [ ] no-sql-extension: Only .sql extension processed

---

## Key Test Scenarios Covered

1. **✓ Non-SQL directories** - Not blocked by SQL detection
2. **✓ Unsupported dialects** - PostgreSQL, MySQL, Snowflake detected as Unknown, skipped with warning
3. **✓ Supported dialects** - T-SQL and PL/SQL detected and packaged without warnings
4. **✓ Partial support** - Mixed dialect projects package supported SQL, skip unsupported with warnings
5. **✓ Edge cases** - Empty files, ambiguous SQL, mixed languages, non-.sql extensions handled correctly

---

## Notes

- Each project has a `README.md` explaining its test purpose
- Each project has `.veracode/auto-package.sh` and `.veracode/manual-package.sh`
- All SQL files use realistic patterns matching their respective dialects
- Test projects intentionally include some security vulnerabilities for realistic testing
- Total of 79 files across 12 test projects
- Organized by test phase for methodical validation
