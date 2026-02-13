# Schema Setup Guide

> **Updated:** 2026-02-13 WITA
>
> How to create your project's Supabase schema and configure it properly.
> For HMWAIntel, the `wa_intel` schema is already created and in use.

---

## Why a Separate Schema?

Each project gets its own PostgreSQL schema (not `public`). This provides:
- **Isolation** — your tables don't interfere with other projects
- **Organization** — clear ownership of tables
- **Security** — RLS policies scoped to your schema
- **PostgREST** — clean API namespacing

---

## Schema Access Pattern

```typescript
// Access wa_intel schema tables
const { data } = await supabase
  .schema('wa_intel')
  .from('your_table')
  .select('*');
```

---

## RLS Patterns

### Pattern 1: Admin-Only (Current)
```sql
CREATE POLICY "admin_only"
  ON wa_intel.table_name FOR ALL
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

### Pattern 2: Authenticated Read
```sql
CREATE POLICY "Authenticated users can read"
  ON wa_intel.table_name FOR SELECT
  TO authenticated
  USING (true);
```

---

## Common Gotchas

| Issue | Fix |
|-------|-----|
| `relation "table" does not exist` | Schema not exposed to PostgREST. Add to API settings. |
| Queries return empty but data exists | RLS policy blocking. Check `pg_policies`. |
| New function not visible to client | Run `NOTIFY pgrst, 'reload schema'` |
| `$` in migration fails | MCP can't handle dollar-quoting. Use single-quote quoting. |
