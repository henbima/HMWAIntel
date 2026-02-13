# Supabase Migration Standards

> Rules for creating and managing database migrations.

---

## Migration File Naming

Format: `YYYYMMDDHHMMSS_descriptive_name.sql`

Examples:
- `20260209120000_create_users_table.sql`
- `20260209130000_add_status_column_to_tasks.sql`

### Rules
- Timestamps must be unique — never reuse
- Only `.sql` files
- Never rename an applied migration
- Names should describe what the migration does

---

## Migration File Location

All migrations go in: `supabase/migrations/`

---

## Migration Content Rules

### Required Elements
1. **Comment header** with purpose
2. **IF NOT EXISTS / IF EXISTS** for idempotency
3. **RLS policies** for any new tables
4. **Permission grants** for `authenticated`, `anon`, `service_role`
5. **UUID primary keys** using `gen_random_uuid()`

### Example
```sql
-- Migration: Create user_preferences table
-- Purpose: Store user notification and display preferences

CREATE TABLE IF NOT EXISTS my_schema.user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  notifications_enabled BOOLEAN DEFAULT true,
  theme VARCHAR(20) DEFAULT 'light',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE my_schema.user_preferences ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can read own preferences"
  ON my_schema.user_preferences FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own preferences"
  ON my_schema.user_preferences FOR UPDATE
  USING (auth.uid() = user_id);

-- Grants
GRANT SELECT, INSERT, UPDATE ON my_schema.user_preferences TO authenticated;
GRANT SELECT ON my_schema.user_preferences TO anon;
GRANT ALL ON my_schema.user_preferences TO service_role;
```

---

## CRITICAL: MCP Compatibility

When executing migrations via Supabase MCP tool:

**NO DOLLAR-QUOTING** — The MCP tool cannot handle `$` characters in SQL.

Bad:
```sql
CREATE FUNCTION my_func() RETURNS void AS $$
BEGIN
  -- code
END;
$$ LANGUAGE plpgsql;
```

Good:
```sql
CREATE FUNCTION my_func() RETURNS void AS '
BEGIN
  -- code
END;
' LANGUAGE plpgsql;
```

For strings containing single quotes, escape them:
```sql
-- Instead of: 'it''s a test'
-- Use: 'it''s a test' (double single-quotes)
```

---

## Destructive Operations

NEVER include these in migrations without explicit user approval:
- `DROP TABLE`
- `DROP COLUMN`
- `TRUNCATE`
- `DELETE FROM` (bulk deletes)

If destructive operations are needed:
1. Create a backup migration first
2. Get user approval
3. Document the reason in the migration comment
