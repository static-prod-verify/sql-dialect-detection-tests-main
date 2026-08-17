# ENG-70110 SQL Dialect Detection - Testing Guide

## Quick Start

All 12 test projects are ready to validate the ENG-70110 fix.

### Location

```shell
cd /Users/rlayzell/dev/static/packager/static-packager-repos/sql/sql-dialect-detection-tests
```

### Test All Projects at Once

```bash
cd /Users/rlayzell/dev/static/packager/static-packager-repos/sql/sql-dialect-detection-tests

for project in non-sql-only postgresql-only mysql-only snowflake-only tsql-supported plsql-supported mixed-postgresql-tsql mixed-mysql-plsql empty-sql-files ambiguous-sql sql-with-non-sql no-sql-extension; do
  echo "=== Testing $project ==="
  cd $project
  bash .veracode/auto-package.sh 2>&1 | tee packaging-$project.log
  cd ..
done
```

## Test Projects by Phase

### Phase 1: Non-SQL Projects

Tests that normal projects without SQL are not affected.

- non-sql-only

**Expected:** No SQL warnings, package created normally

---

### Phase 2: Unsupported Dialects

Tests that unsupported SQL dialects trigger warnings and are skipped.

- postgresql-only
- mysql-only
- snowflake-only

**Expected for each:**

- Warning: "SQL source code discovered in an unsupported dialect. Only PL/SQL and T-SQL are supported."
- SQL NOT packaged

---

### Phase 3: Supported Dialects

Tests that supported dialects are packaged without warnings.

- tsql-supported
- plsql-supported

**Expected for each:**

- NO warnings
- SQL packaged successfully

---

### Phase 4: Mixed Dialects

Tests partial support with both supported and unsupported SQL.

- mixed-postgresql-tsql
- mixed-mysql-plsql

**Expected for each:**

- Warning about unsupported dialect
- Only supported dialect packaged
- Unsupported dialect skipped

---

### Phase 5: Edge Cases

Tests robustness with unusual but realistic scenarios.

- empty-sql-files
- ambiguous-sql
- sql-with-non-sql
- no-sql-extension

**Expected:**

- empty-sql-files: T-SQL detected despite empty files
- ambiguous-sql: Warning about unsupported dialect
- sql-with-non-sql: All file types packaged
- no-sql-extension: Only .sql extension processed

---

## Validation Checklist

After running all tests, verify:

### Non-SQL Projects ✓

- [ ] `non-sql-only` packaged without SQL warnings

### Unsupported Dialect Detection ✓

- [ ] `postgresql-only` shows warning about unsupported dialect
- [ ] `mysql-only` shows warning about unsupported dialect
- [ ] `snowflake-only` shows warning about unsupported dialect

### Supported Dialect Packaging ✓

- [ ] `tsql-supported` packaged without warnings
- [ ] `plsql-supported` packaged without warnings

### Mixed Dialect Handling ✓

- [ ] `mixed-postgresql-tsql` packages T-SQL, skips PostgreSQL
- [ ] `mixed-mysql-plsql` packages PL/SQL, skips MySQL

### Edge Case Robustness ✓

- [ ] `empty-sql-files` detects T-SQL despite empty files
- [ ] `ambiguous-sql` warns about unsupported dialect
- [ ] `sql-with-non-sql` includes all source types
- [ ] `no-sql-extension` processes only .sql files

---

## Key Implementation Details

### What the Fix Changes

**Before ENG-70110:**

- May have packaged unsupported SQL dialects
- Possibly unclear warning messages
- Logic may have been more complex

**After ENG-70110:**

- ONLY packages T-SQL and PL/SQL
- Clear warning: "Only PL/SQL and T-SQL are supported"
- Simplified detection (PostgreSQL/MySQL detection removed as redundant)
- Non-SQL directories NOT blocked

### PostgreSQL/MySQL Detection Removal

The fix removes the explicit PostgreSQL and MySQL detection that was preventing false positives. Instead, all non-{T-SQL, PL/SQL} SQL becomes Unknown, which is then skipped with the same warning.

**Why?** Because the end result is identical - unsupported SQL is not packaged. The specific dialect doesn't matter for the warning.

---

## Test Results Interpretation

### ✓ PASS: Test succeeds if

1. Non-SQL projects proceed normally
2. Unsupported dialects show exact warning message
3. Supported dialects package without warnings
4. Mixed dialects show selective packaging
5. Edge cases handled robustly

### ✗ FAIL: Test fails if

1. Non-SQL projects blocked by SQL detection
2. Unsupported warning message is incomplete/different
3. Supported dialects show warnings
4. Mixed dialects package wrong dialect
5. Edge cases cause errors

---

## Troubleshooting

### Issue: No warning shown for unsupported dialect

**Check:**

- Is the SQL code in the `database/` directory?
- Do the SQL files have `.sql` extension?
- Are there enough lines of actual SQL? (Empty files won't trigger detection)

### Issue: T-SQL/PL/SQL shown as unsupported

**Check:**

- Did the fix get deployed correctly?
- Are T-SQL/PL/SQL keyword counts above threshold (30-keyword difference)?
- Are the detection files updated?

### Issue: Package doesn't contain SQL

**Expected for:** postgresql-only, mysql-only, snowflake-only, ambiguous-sql  
**Unexpected for:** tsql-supported, plsql-supported

Check if the project is in the unsupported list above.

---

## Related Documentation

- [TEST_PROJECTS_INDEX.md](TEST_PROJECTS_INDEX.md) - Detailed project descriptions
- Individual project README.md files in each test project directory
- ENG-70110 JIRA ticket for implementation details

---

## Next Steps After Validation

If all tests pass:

1. Merge ENG-70110 fix to main branch
2. Deploy packager with updated SQL detection
3. Document warning messages in user-facing docs
4. Create Viper functional tests
5. Add the Viper tests to long running CI/CD pipeline

If tests fail:

1. Review the specific failing test project README
2. Compare against expected behavior in TESTING_GUIDE
3. Check implementation details in ENG-70110 JIRA
4. Iterate on fix and re-test
