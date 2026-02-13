# Database Governance Standards

> Core rules for database access, changes, and migration workflow.

---

## Core Rules

### 1. Service Layer Only
- Components NEVER query the database directly
- All DB access goes through service functions
- Service functions handle errors and return typed results

### 2. Migrations Only
- Schema changes ONLY via migration files
- Never use raw SQL in the Supabase dashboard for schema changes
- Always save migration to `supabase/migrations/`

### 3. Schema First
- Before writing any query, verify the actual schema
- Use `information_schema.columns` to check table structure
- Never assume a column exists — verify first

### 4. Reuse First
- Before creating a new table, check if existing tables can serve the need
- Before adding a column, check if a similar column already exists
- Consolidate related data into fewer tables when possible

---

## Migration Workflow

### Step 1: Discover
```sql
-- Check what exists
SELECT table_name FROM information_schema.tables
WHERE table_schema = '<SCHEMA_NAME>'
ORDER BY table_name;

-- Check table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = '<TABLE>' AND table_schema = '<SCHEMA_NAME>'
ORDER BY ordinal_position;
```

### Step 2: Plan
- Document what needs to change and why
- Present to user for approval
- Consider impact on existing data and queries

### Step 3: Write Migration
- Follow migration naming convention: `YYYYMMDDHHMMSS_name.sql`
- Include all required elements (see `supabase-migration-standards.md`)
- Save to `supabase/migrations/`

### Step 4: Apply
- Use Supabase MCP `apply_migration` or `execute_sql` tool
- Verify the migration was applied successfully
- Check that the schema matches expectations

### Step 5: Verify
- Run a test query against the changed table
- Verify RLS policies work correctly
- Update any affected service functions or types
- Run `NOTIFY pgrst, 'reload schema'` to refresh PostgREST cache

---

## Enforcement Checklist

Before approving any database change:
- [ ] Migration file follows naming convention
- [ ] IF NOT EXISTS / IF EXISTS used
- [ ] RLS policies included for new tables
- [ ] UUID primary keys with gen_random_uuid()
- [ ] Grants to authenticated, anon, service_role
- [ ] No dollar-quoting (MCP compatibility)
- [ ] No destructive operations without explicit approval
