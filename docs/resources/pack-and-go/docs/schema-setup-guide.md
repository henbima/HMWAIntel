# Schema Setup Guide

> **Updated:** 2026-02-11 22:00 WITA
>
> How to create your project's Supabase schema and configure it properly.

---

## Why a Separate Schema?

Each project gets its own PostgreSQL schema (not `public`). This provides:
- **Isolation** — your tables don't interfere with other projects
- **Organization** — clear ownership of tables
- **Security** — RLS policies scoped to your schema
- **PostgREST** — clean API namespacing

---

## Step 1: Create the Schema

Via Supabase MCP (`execute_sql`):

```sql
-- Create the project schema
CREATE SCHEMA IF NOT EXISTS {{SCHEMA_NAME}};

-- Grant usage to PostgREST roles
GRANT USAGE ON SCHEMA {{SCHEMA_NAME}} TO anon, authenticated, service_role;

-- Grant default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA {{SCHEMA_NAME}}
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO authenticated;

ALTER DEFAULT PRIVILEGES IN SCHEMA {{SCHEMA_NAME}}
GRANT SELECT ON TABLES TO anon;

ALTER DEFAULT PRIVILEGES IN SCHEMA {{SCHEMA_NAME}}
GRANT ALL ON TABLES TO service_role;
```

---

## Step 2: Expose Schema to PostgREST

The schema must be added to PostgREST's `db_schemas` config. Via Supabase dashboard:

1. Go to **Settings → API → API Settings**
2. Add your schema to the "Extra schemas" list
3. Or via SQL: contact Supabase support / use dashboard

Via API header (client-side):
```typescript
// For queries in your schema
const { data } = await supabase
  .schema('{{SCHEMA_NAME}}')
  .from('your_table')
  .select('*');
```

---

## Step 3: Create Tables

Follow migration standards (see `.kiro/steering/supabase-migration-standards.md`):

```sql
-- Migration: Create initial tables
-- Purpose: Set up core data tables for {{PROJECT_NAME}}
-- Date: YYYY-MM-DD

CREATE TABLE IF NOT EXISTS {{SCHEMA_NAME}}.example_table (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE {{SCHEMA_NAME}}.example_table ENABLE ROW LEVEL SECURITY;

-- RLS Policy: authenticated users can read
CREATE POLICY "Authenticated users can read"
  ON {{SCHEMA_NAME}}.example_table FOR SELECT
  TO authenticated
  USING (true);

-- Grants
GRANT ALL ON {{SCHEMA_NAME}}.example_table TO authenticated;
GRANT SELECT ON {{SCHEMA_NAME}}.example_table TO anon;
GRANT ALL ON {{SCHEMA_NAME}}.example_table TO service_role;
```

---

## Step 4: RLS Patterns

### Pattern 1: Admin-Only (Phase 0)
```sql
CREATE POLICY "admin_only"
  ON {{SCHEMA_NAME}}.table_name FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM hm_core.user_role_assignments ura
      JOIN hm_core.roles r ON ura.role_id = r.id
      WHERE ura.user_id = auth.uid()
      AND r.role_code IN ('SYSTEM_ADMIN', 'DIRECTOR')
      AND ura.is_active = true
    )
  );
```

### Pattern 2: Role-Based with Store Scoping (Phase 3)
```sql
CREATE POLICY "role_based_with_scope"
  ON {{SCHEMA_NAME}}.table_name FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM hm_core.user_role_assignments ura
      JOIN hm_core.roles r ON ura.role_id = r.id
      WHERE ura.user_id = auth.uid()
      AND ura.is_active = true
      AND (
        ura.scope_type = 'GLOBAL'
        OR (ura.scope_type = 'STORE' AND ura.scope_value = table_name.store_code)
      )
    )
  );
```

### Pattern 3: Helper Function (Recommended for Complex RLS)
```sql
-- Create a helper function (avoids repeating RLS logic)
CREATE OR REPLACE FUNCTION {{SCHEMA_NAME}}.user_can_access_store(p_store_code TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql SECURITY DEFINER AS '
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM hm_core.user_role_assignments ura
    WHERE ura.user_id = auth.uid()
    AND ura.is_active = true
    AND (ura.scope_type = ''GLOBAL'' OR ura.scope_value = p_store_code)
  );
END;
';

-- Then use in policies:
CREATE POLICY "scoped_access"
  ON {{SCHEMA_NAME}}.table_name FOR SELECT
  TO authenticated
  USING ({{SCHEMA_NAME}}.user_can_access_store(store_code));
```

---

## Step 5: Service Layer

Access your schema from React:

```typescript
// src/modules/{module}/services/{module}Service.ts

import { supabase } from '@shared/services/supabase';

export interface ExampleRow {
  id: string;
  name: string;
  description: string | null;
  created_at: string;
}

export async function getExamples(): Promise<{ data: ExampleRow[] | null; error: string | null }> {
  const { data, error } = await supabase
    .schema('{{SCHEMA_NAME}}')
    .from('example_table')
    .select('*')
    .order('created_at', { ascending: false });

  if (error) {
    return { data: null, error: error.message };
  }
  return { data, error: null };
}
```

---

## Common Gotchas

| Issue | Fix |
|-------|-----|
| `relation "table" does not exist` | Schema not exposed to PostgREST. Add to API settings. |
| Queries return empty but data exists | RLS policy blocking. Check `pg_policies`. |
| UPSERT returns 409 Conflict | Need `?on_conflict=col1,col2` for unique constraints. |
| New function not visible to client | Run `NOTIFY pgrst, 'reload schema'` |
| `$$` in migration fails | MCP can't handle `$`. Use single-quote quoting. |
