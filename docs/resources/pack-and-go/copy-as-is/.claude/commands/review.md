Perform a self-review of the current changes against project conventions. Check for these violations:

## Critical Constraint Checks

### 1. Schema Usage
Search changed files for `supabase.from(` without `.schema(...)`:
- Run: `git diff --name-only --diff-filter=AM` and filter for .tsx/.ts files
- Check each file for raw `supabase.from('table')` calls
- Correct: `supabase.schema('<project_schema>').from('table')`
- Exception: auth-related calls that use Supabase Auth API directly

### 2. TypeScript Safety
Search changed files for `any` type usage:
- Look for `: any`, `as any`, `<any>` patterns
- All types should use interfaces from the project's type files

### 3. Unguarded Array Operations
Check changed files for array operations without defensive guards:
- Look for `.map(`, `.filter(`, `.length` on variables that could be null/undefined
- Correct: `(array || []).map(...)` or optional chaining

### 4. Auth State Handling
Check if new pages/components properly handle auth:
- Must use `useAuth()` for protected content
- Must show loading state while auth is resolving
- Must handle unauthenticated state gracefully

### 5. Hardcoded Values
Check for hardcoded:
- Store/outlet names (should come from DB)
- User roles (should use config/env)
- API URLs (should use env variables)
- Supabase project IDs or keys

### 6. Migration Files
If `supabase/migrations/` files were added:
- Check tables use the project schema (not `public`)
- Check RLS policies are included
- Check UUID primary keys with `gen_random_uuid()`
- Check proper grants to `authenticated`, `anon`, `service_role`
- Check NO dollar-quoting (`$$`)

## Report Format
For each category, report:
- PASS or FAIL
- If FAIL: list the specific files and line numbers
- Provide the fix for each violation found
