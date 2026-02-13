# Database Boundary Governance Template

## Overview
This is a portable template for any application sharing the HollyMart Supabase database.
Copy this file to your project's `.kiro/steering/` directory and fill in the variables.

## Setup Instructions

1. Copy this file to `.kiro/steering/database-boundary-governance.md`
2. Replace all `{PLACEHOLDERS}` with your app's values
3. Add `inclusion: always` front-matter
4. Verify by querying: `SELECT * FROM hm_core.object_registry WHERE owner_app = '{APP_PREFIX}'`

## Template Variables

| Variable | Description | HMCS Example | HMBI Example |
|----------|-------------|--------------|--------------|
| `{APP_PREFIX}` | Your app's prefix | `hmcs` | `hmbi` |
| `{APP_FULL_NAME}` | Full application name | HollyMart Control System | HollyMart Business Intelligence |
| `{ALLOWED_SCHEMAS}` | Schemas you can modify | `public, training, wa_intel` | `hmbi` |
| `{SHARED_SCHEMAS}` | Read-only shared schemas | `hm_core` | `hm_core` |
| `{FORBIDDEN_SCHEMAS}` | Schemas you must NEVER modify | `hmbi` | `public` |

---

## Template Content

```
---
inclusion: always
---

# Database Boundary Governance — {APP_FULL_NAME}

## App Identity
- **This project**: `{APP_PREFIX}` ({APP_FULL_NAME})
- **Allowed schemas**: {ALLOWED_SCHEMAS}
- **Shared schemas** (read-only unless shared ownership): {SHARED_SCHEMAS}
- **Other app schemas** (NEVER modify): {FORBIDDEN_SCHEMAS}

## Mandatory Registry Check

**Before ANY `DROP`, `ALTER`, `DELETE`, `TRUNCATE`, or `cron.unschedule()` operation:**

1. Query the object registry:
   SELECT owner_app, description
   FROM hm_core.object_registry
   WHERE object_type = '{type}' AND object_name = '{name}';

2. If `owner_app != '{APP_PREFIX}'` → STOP. Do NOT proceed.
3. If object not found in registry → STOP. Ask the user.
4. If `owner_app = '{APP_PREFIX}'` → Proceed.

## Naming Convention for New Objects

| Object Type | Format | Example |
|-------------|--------|---------|
| Table (in own schema) | No prefix needed | `{ALLOWED_SCHEMAS}.my_table` |
| Table (in public, new) | `{APP_PREFIX}_{name}` | `{APP_PREFIX}_audit_log` |
| Function | `{APP_PREFIX}__{verb}_{noun}()` | `{APP_PREFIX}__compute_summary()` |
| Cron Job | `{APP_PREFIX}_{descriptive-name}` | `{APP_PREFIX}_daily-sync` |
| Edge Function | `{APP_PREFIX}-{descriptive-name}` | `{APP_PREFIX}-process-data` |

## Registration Requirement

After creating ANY new database object:
INSERT INTO hm_core.object_registry (object_type, object_name, object_schema, owner_app, description)
VALUES ('{type}', '{name}', '{schema}', '{APP_PREFIX}', '{description}');

## Forbidden Operations

NEVER do these without explicit user confirmation:
- DROP TABLE on any table not owned by `{APP_PREFIX}`
- ALTER TABLE on any table not owned by `{APP_PREFIX}`
- cron.unschedule() on any cron job not prefixed with `{APP_PREFIX}_`
- Any DDL in schemas listed in {FORBIDDEN_SCHEMAS}

## Fallback Rule

If hm_core.object_registry is unavailable:
1. Check object name prefix
2. Check schema ownership
3. If ambiguous → STOP and ask the user
```

## Registry Query Examples

```sql
-- Check what your app owns
SELECT object_type, object_name, description
FROM hm_core.object_registry
WHERE owner_app = '{APP_PREFIX}'
ORDER BY object_type, object_name;

-- Check who owns a specific object before modifying
SELECT owner_app, description
FROM hm_core.object_registry
WHERE object_name = 'some_table' AND object_type = 'table';

-- Full registry overview
SELECT owner_app, object_type, COUNT(*)
FROM hm_core.object_registry
GROUP BY owner_app, object_type
ORDER BY owner_app, object_type;
```

## App Prefix Registry

| Prefix | Full Name | Primary Schema |
|--------|-----------|---------------|
| `hm` | HollyMart Core | `hm_core` |
| `hmcs` | HollyMart Control System | `public` |
| `hmbi` | HollyMart Business Intelligence | `hmbi` |
| `training` | Training Module | `training` |
| `wa_intel` | WhatsApp Intelligence | `wa_intel` |

## Background

On 2026-02-12, an AI assistant working on HMBI accidentally deleted HMCS's daily task generation cron job. This template and the `hm_core.object_registry` system were created to prevent such cross-app interference.

See: ADR-006 (Multi-App Naming Convention), Spec 631
