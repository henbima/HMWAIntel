Before making any database changes, perform these pre-flight checks:

## Agent Delegation (Cost Optimization — MANDATORY)

When running as Opus, delegate checks 1-4 to a **Sonnet** subagent (file reads + SQL queries). Opus only reviews the findings and presents the report (step 6) to the user.

## 1. Review Schema Reference
Read `hmso_setup.sql` to understand the current schema. All tables live in the **`hmso`** schema.

## 2. Verify Schema via Supabase MCP
For the table(s) you plan to modify, verify the actual columns:
```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = '<TABLE_NAME>' AND table_schema = 'hmso'
ORDER BY ordinal_position;
```

## 3. Check Existing RLS Policies
```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE schemaname = 'hmso' AND tablename = '<TABLE_NAME>';
```

## 4. Check Existing Migrations
List recent migrations in `supabase/migrations/` to understand what's already been applied.

## 5. Migration Rules Reminder
When creating migrations:
- All tables belong in the `hmso` schema (not `public`)
- Use `IF NOT EXISTS` / `IF EXISTS` for idempotent operations
- Include proper RLS policies for any new tables
- Use UUID primary keys (`gen_random_uuid()`)
- Grant permissions to `authenticated`, `anon`, and `service_role`
- Save migration files to `supabase/migrations/` with timestamp prefix

## 6. Report
Present your findings:
- Current table structure
- Current RLS policies
- Proposed changes
- Migration SQL (if applicable)

Wait for approval before applying any migration.
