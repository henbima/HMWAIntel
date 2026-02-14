---
inclusion: always
version: 1.0.0
last-updated: 2026-02-13
---

# Database Boundary Governance — HMSO (HollyMart Signal Operations)

> **Reference:** HMCS Spec 631, ADR-006 (Multi-App Naming Convention)
> **Why:** On 2026-02-12, an AI assistant accidentally deleted another app's production cron job because there were no ownership markers in the shared database.

## App Identity
- **This project**: `hmso` (HMSO — HollyMart Signal Operations, database schema uses legacy name `hmso`)
- **Allowed schemas**: `hmso` (our own schema — full read/write)
- **Shared schemas** (read-only unless shared ownership): `hm_core`
- **Other app schemas** (NEVER modify): Any schema not listed above (`public`, `hmbi`, `hmcs`, `training`, etc.)

## Mandatory Registry Check

**Before ANY `DROP`, `ALTER`, `DELETE`, `TRUNCATE`, or `cron.unschedule()` operation:**

1. Query the object registry:
   ```sql
   SELECT owner_app, description
   FROM hm_core.object_registry
   WHERE object_type = '{type}' AND object_name = '{name}';
   ```

2. If `owner_app != 'hmso'` → **STOP. Do NOT proceed.** Tell the user this object belongs to another app.
3. If object not found in registry → **STOP. Ask the user.**
4. If `owner_app = 'hmso'` → Proceed with caution.

## Naming Convention for New Objects

| Object Type | Format | Example |
|-------------|--------|---------|
| Table (in `hmso` schema) | No prefix needed | `hmso.my_table` |
| Table (in `public`, if ever needed) | `hmso_{name}` | `hmso_audit_log` |
| Function | `hmso__{verb}_{noun}()` | `hmso__compute_summary()` |
| Cron Job | `hmso_{descriptive-name}` | `hmso_daily-sync` |
| Edge Function | `hmso-{descriptive-name}` | `hmso-process-data` |

## Registration Requirement

After creating ANY new database object, register it:
```sql
INSERT INTO hm_core.object_registry (object_type, object_name, object_schema, owner_app, description)
VALUES ('{type}', '{name}', '{schema}', 'hmso', '{description}');
```

## Forbidden Operations

**NEVER do these without explicit user confirmation AND registry check:**
- `DROP TABLE` on any table not owned by `hmso`
- `ALTER TABLE` on any table not owned by `hmso`
- `cron.unschedule()` on any cron job not prefixed with `hmso_`
- Any DDL in schemas not listed in "Allowed schemas" above
- Deleting or modifying Edge Functions not prefixed with `hmso-`

## Fallback Rule

If `hm_core.object_registry` is unavailable:
1. Check object name prefix — if it doesn't start with `hmso`, do NOT touch it
2. Check schema ownership — if it's not in `hmso` schema, do NOT touch it
3. If ambiguous → **STOP and ask the user**

## App Prefix Registry

| Prefix | Full Name | Primary Schema |
|--------|-----------|---------------|
| `hm` | HollyMart Core | `hm_core` |
| `hmcs` | HollyMart Control System | `public` |
| `hmbi` | HollyMart Business Intelligence | `hmbi` |
| `training` | Training Module | `training` |
| `hmso` | HMSO — Signal Operations | `hmso` |

## Quick Reference Queries

```sql
-- What does this project own?
SELECT object_type, object_name, description
FROM hm_core.object_registry
WHERE owner_app = 'hmso'
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
