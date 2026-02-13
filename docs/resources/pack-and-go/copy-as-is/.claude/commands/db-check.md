Before making any database changes, perform these pre-flight checks:

## 1. Review Current Schema
Check CLAUDE.md for the project's schema name and conventions.

## 2. Verify Schema via Supabase MCP
For the table(s) you plan to modify, verify the actual columns:
```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = '<TABLE_NAME>' AND table_schema = '<PROJECT_SCHEMA>'
ORDER BY ordinal_position;
```

## 3. Check Existing RLS Policies
```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE schemaname = '<PROJECT_SCHEMA>' AND tablename = '<TABLE_NAME>';
```

## 4. Check Existing Migrations
List recent migrations in `supabase/migrations/` to understand what's already been applied.

## 5. Migration Rules Reminder
When creating migrations:
- All tables belong in the project schema (not `public`)
- Use `IF NOT EXISTS` / `IF EXISTS` for idempotent operations
- Include proper RLS policies for any new tables
- Use UUID primary keys (`gen_random_uuid()`)
- Grant permissions to `authenticated`, `anon`, and `service_role`
- Save migration files to `supabase/migrations/` with timestamp prefix
- NO dollar-quoting (`$$`) — use single-quote quoting for MCP compatibility

## 6. Report
Present your findings:
- Current table structure
- Current RLS policies
- Proposed changes
- Migration SQL (if applicable)

Wait for approval before applying any migration.
