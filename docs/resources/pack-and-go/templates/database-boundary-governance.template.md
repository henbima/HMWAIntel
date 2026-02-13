---
inclusion: always
---

# Database Boundary Governance — {{PROJECT_FULL_NAME}}

> **Target:** `.kiro/steering/database-boundary-governance.md`
> **Reference:** HMCS Spec 631, ADR-006 (Multi-App Naming Convention)
> **Why:** On 2026-02-12, an AI assistant accidentally deleted another app's production cron job because there were no ownership markers in the shared database.

## App Identity
- **This project**: `{{SCHEMA_NAME}}` ({{PROJECT_FULL_NAME}})
- **Allowed schemas**: `{{SCHEMA_NAME}}` (our own schema — full read/write)
- **Shared schemas** (read-only unless shared ownership): `hm_core`
- **Other app schemas** (NEVER modify): Any schema not listed above (`public`, `hmbi`, `hmcs`, `training`, `wa_intel`, etc.)

## Mandatory Registry Check

**Before ANY `DROP`, `ALTER`, `DELETE`, `TRUNCATE`, or `cron.unschedule()` operation:**

1. Query the object registry:
   ```sql
   SELECT owner_app, description
   FROM hm_core.object_registry
   WHERE object_type = '{type}' AND object_name = '{name}';
   ```

2. If `owner_app != '{{SCHEMA_NAME}}'` → **STOP. Do NOT proceed.** Tell the user this object belongs to another app.
3. If object not found in registry → **STOP. Ask the user.**
4. If `owner_app = '{{SCHEMA_NAME}}'` → Proceed with caution.

## Naming Convention for New Objects

| Object Type | Format | Example |
|-------------|--------|---------|
| Table (in `{{SCHEMA_NAME}}` schema) | No prefix needed | `{{SCHEMA_NAME}}.my_table` |
| Table (in `public`, if ever needed) | `{{SCHEMA_NAME}}_{name}` | `{{SCHEMA_NAME}}_audit_log` |
| Function | `{{SCHEMA_NAME}}__{verb}_{noun}()` | `{{SCHEMA_NAME}}__compute_summary()` |
| Cron Job | `{{SCHEMA_NAME}}_{descriptive-name}` | `{{SCHEMA_NAME}}_daily-sync` |
| Edge Function | `{{SCHEMA_NAME}}-{descriptive-name}` | `{{SCHEMA_NAME}}-process-data` |

## Registration Requirement

After creating ANY new database object, register it:
```sql
INSERT INTO hm_core.object_registry (object_type, object_name, object_schema, owner_app, description)
VALUES ('{type}', '{name}', '{schema}', '{{SCHEMA_NAME}}', '{description}');
```

## Forbidden Operations

**NEVER do these without explicit user confirmation AND registry check:**
- `DROP TABLE` on any table not owned by `{{SCHEMA_NAME}}`
- `ALTER TABLE` on any table not owned by `{{SCHEMA_NAME}}`
- `cron.unschedule()` on any cron job not prefixed with `{{SCHEMA_NAME}}_`
- Any DDL in schemas not listed in "Allowed schemas" above
- Deleting or modifying Edge Functions not prefixed with `{{SCHEMA_NAME}}-`

## Fallback Rule

If `hm_core.object_registry` is unavailable:
1. Check object name prefix — if it doesn't start with `{{SCHEMA_NAME}}`, do NOT touch it
2. Check schema ownership — if it's not in `{{SCHEMA_NAME}}` schema, do NOT touch it
3. If ambiguous → **STOP and ask the user**

## App Prefix Registry

| Prefix | Full Name | Primary Schema |
|--------|-----------|---------------|
| `hm` | HollyMart Core | `hm_core` |
| `hmcs` | HollyMart Control System | `public` |
| `hmbi` | HollyMart Business Intelligence | `hmbi` |
| `training` | Training Module | `training` |
| `wa_intel` | WhatsApp Intelligence | `wa_intel` |

> Add your project here after setup.

## Quick Reference Queries

```sql
-- What does this project own?
SELECT object_type, object_name, description
FROM hm_core.object_registry
WHERE owner_app = '{{SCHEMA_NAME}}'
ORDER BY object_type, object_name;

-- Who owns this object? (check before modifying)
SELECT owner_app, description
FROM hm_core.object_registry
WHERE object_name = 'some_object';

-- Full registry overview
SELECT owner_app, object_type, COUNT(*)
FROM hm_core.object_registry
GROUP BY owner_app, object_type
ORDER BY owner_app, object_type;
```
