# Test Case: Non-SQL Project (Java + TypeScript)

## Purpose

Test that projects containing only non-SQL source code (Java, TypeScript, etc.) are NOT blocked by SQL detection logic and proceed with normal packaging.

## Test Case Description

This project simulates a typical multi-language application stack:

- **Backend**: Java Spring Boot REST API (no direct SQL code)
- **Frontend**: TypeScript/React web application
- **Database Access**: Uses ORMs and stored procedures from database, but no `.sql` files in project

## Project Structure

```
non-sql-only/
├── java-app/                              # Java backend
│   ├── src/main/java/com/example/
│   │   ├── Application.java
│   │   ├── UserController.java
│   │   └── UserRepository.java
│   ├── pom.xml
│   └── application.yml
├── frontend/                              # TypeScript frontend
│   ├── src/
│   │   ├── App.tsx
│   │   ├── UserService.ts
│   │   └── index.tsx
│   └── package.json
├── .gitignore
├── .veracode/
│   ├── auto-package.sh
│   └── manual-package.sh
└── README.md
```

## Expected Behavior

1. **Packager runs without errors** - No SQL detection should be attempted
2. **No SQL-related warnings** - No "[WARN] SQL source code" messages
3. **Non-SQL code packaged normally** - Java and TypeScript source included
4. **No database/ directory** - Project has no SQL files at all

## Verification Steps

### Step 1: Run the Packager

```bash
cd /Users/rlayzell/dev/static/packager/static-packager-repos/sql/non-sql-only
bash .veracode/auto-package.sh
```

### Step 2: Inspect Output

- Look for any warnings starting with "[WARN] SQL"
- Verify NO warning about "SQL source code discovered"
- Check that package was created successfully

### Step 3: Verify Package Contents

```bash
cd .veracode/output
unzip -l non-sql-only.zip | grep -E "\.(java|ts|tsx)$"
```

Expected: Java and TypeScript files present in package

### Step 4: Confirm Expected Result

✅ **PASS**: No SQL warnings, package created with non-SQL code only
❌ **FAIL**: SQL warnings appear, or packaging fails

## Test Data

### Backend: Java Spring Boot

- Simple REST API controller
- User repository with JPA/Hibernate (ORM)
- No embedded SQL - all data access via ORM

### Frontend: TypeScript/React

- React components
- Service layer for API calls
- No SQL code

## Exit Code Expectations

- Exit code **0** (success)
- No database/ directory should exist
- No .sql files in the project

## Notes

- This is a **baseline test** - should always pass as there's no SQL involved
- Tests that the packager doesn't incorrectly trigger SQL logic on non-SQL projects
- Ensures that absence of SQL doesn't cause packaging to fail
