Before making any database changes, perform these pre-flight checks:

## 1. Review Schema Reference
Read `wa_intel_setup.sql` to understand the current schema. All tables live in the **`wa_intel`** schema.

## 2. Verify Schema via Supabase MCP
For the table(s) you plan to modify, verify the actual columns:
```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = '<TABLE_NAME>' AND table_schema = 'wa_intel'
ORDER BY ordinal_position;
```

## 3. Check Existing RLS Policies
```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE schemaname = 'wa_intel' AND tablename = '<TABLE_NAME>';
```

## 4. Check Existing Migrations
List recent migrations in `supabase/migrations/` to understand what's already been applied.

## 5. Migration Rules Reminder
When creating migrations:
- All tables belong in the `wa_intel` schema (not `public`)
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
