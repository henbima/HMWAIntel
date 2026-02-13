# 631: Multi-App Database Boundary Governance - Design

## Architecture Overview

This spec implements a 4-layer defense system to prevent cross-app interference in a shared Supabase database:

1. **Schema Isolation** (existing) — each app has its own schema
2. **Naming Convention** (new) — future objects get app prefix for instant visual identification
3. **Object Registry** (new) — `hm_core.object_registry` as single source of truth for ownership
4. **AI Steering Rules** (new) — mandatory check-before-modify rules in every project

## Database Changes

### New Table: `hm_core.object_registry`

```sql
CREATE TABLE hm_core.object_registry (
  id SERIAL PRIMARY KEY,
  object_type TEXT NOT NULL CHECK (object_type IN (
    'table', 'function', 'cron_job', 'edge_function', 'schema', 'view', 'trigger'
  )),
  object_name TEXT NOT NULL,
  object_schema TEXT DEFAULT 'public',
  owner_app TEXT NOT NULL CHECK (owner_app IN (
    'hmcs', 'hmbi', 'shared', 'training', 'wa_intel'
  )),
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(object_type, object_name, object_schema)
);

-- Allow all authenticated users to read (AI assistants query this)
ALTER TABLE hm_core.object_registry ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read object registry"
  ON hm_core.object_registry FOR SELECT
  USING (true);

-- Only service role can insert/update (migrations only)
CREATE POLICY "Service role can manage registry"
  ON hm_core.object_registry FOR ALL
  USING (auth.role() = 'service_role');

-- Index for fast lookups
CREATE INDEX idx_object_registry_lookup 
  ON hm_core.object_registry(object_type, object_name);

CREATE INDEX idx_object_registry_owner 
  ON hm_core.object_registry(owner_app);
```

### Rollback Plan
```sql
DROP TABLE IF EXISTS hm_core.object_registry;
```

### Cron Job Rename
```sql
-- Rename existing cron jobs with app prefix
-- This is safe: cron job names are labels, not referenced in code

-- Step 1: Unschedule old names
SELECT cron.unschedule('generate-daily-tasks');
SELECT cron.unschedule('analyze-daily');
SELECT cron.unschedule('daily-briefing');

-- Step 2: Reschedule with prefixed names (same schedule, same command)
SELECT cron.schedule('hmcs_generate-daily-tasks', '5 16 * * *', '<same command>');
SELECT cron.schedule('hmbi_analyze-daily', '0 18 * * *', '<same command>');
SELECT cron.schedule('hmbi_daily-briefing', '0 22 * * *', '<same command>');
```

### SQL Comments on Critical Objects
```sql
COMMENT ON TABLE daily_tasks IS 'OWNER: hmcs | Daily task instances generated from templates. DO NOT DROP/ALTER from other apps.';
COMMENT ON TABLE task_templates IS 'OWNER: hmcs | Task template definitions. DO NOT DROP/ALTER from other apps.';
COMMENT ON TABLE task_submissions IS 'OWNER: hmcs | Task submission records. DO NOT DROP/ALTER from other apps.';
-- (additional comments for all critical tables)
```

## Naming Convention Design

### App Prefix Registry

| Prefix | Full Name | Description |
|--------|-----------|-------------|
| `hm` | HollyMart Core | Shared master data (users, outlets, departments, job_roles) |
| `hmcs` | HollyMart Control System | Task management, SOP, compliance |
| `hmbi` | HollyMart Business Intelligence | Sales analytics, reporting, dashboards |
| `training` | Training Module | Training materials, assignments, quizzes |
| `wa_intel` | WhatsApp Intelligence | Message analysis, group management |

### Naming Rules Per Object Type

#### Tables
- **In own schema**: No prefix needed (schema IS the namespace)
  - `hmbi.daily_sales_summary` ✅
  - `training.materials` ✅
- **In `public` schema** (future): Must have app prefix
  - `hmcs_audit_log` ✅
  - `audit_log` ❌ (ambiguous)
- **Legacy in `public`**: Leave as-is, register in object_registry

#### Functions
- **Format**: `{app}__{verb}_{noun}()`
- **Double underscore** separates prefix from function name
- Examples:
  - `hmcs__generate_daily_tasks()`
  - `hmbi__compute_exception_summary()`
  - `hm__get_user_role()`
- **Legacy**: Leave as-is, register in object_registry

#### Cron Jobs
- **Format**: `{app}_{descriptive-name}`
- Examples:
  - `hmcs_generate-daily-tasks`
  - `hmbi_analyze-daily`
  - `hmbi_daily-briefing`

#### Edge Functions
- **Format**: `{app}-{descriptive-name}`
- Examples (future only):
  - `hmcs-generate-daily-tasks`
  - `hmbi-import-purchase-orders`
- **Legacy**: Leave as-is, register in object_registry
- **Note**: Edge function slugs are part of URLs — never rename existing ones

#### Schemas
- **Format**: `{app_prefix}` or `{app_prefix}_{module}`
- Already in use: `hmbi`, `hm_core`, `training`, `wa_intel`
- Future: `hmhr`, `hmpos`, etc.

### What NOT to Prefix
- Supabase system schemas (`auth`, `storage`, `realtime`)
- PostgreSQL extension functions (`pg_trgm`, etc.)
- Supabase-generated objects
- Existing legacy objects (register them instead)

## AI Steering Template Design

### Template Variables
Each project fills in these variables:

| Variable | HMCS Value | HMBI Value |
|----------|------------|------------|
| `{APP_PREFIX}` | `hmcs` | `hmbi` |
| `{ALLOWED_SCHEMAS}` | `public, training, wa_intel` | `hmbi` |
| `{SHARED_SCHEMAS}` | `hm_core` | `hm_core` |

### Template Content (Universal)

The steering file will contain:
1. App identity declaration
2. Mandatory registry check before any modify/delete/drop/unschedule
3. Naming convention rules for new objects
4. Registration requirement after creating new objects
5. Forbidden operations list (cron.unschedule, DROP TABLE, etc. on unowned objects)

### How It Stays Updated
- The registry is the source of truth (lives in the database)
- The steering template references the registry (not a static list)
- When any app creates a new object, it registers it in the same transaction
- No cross-project sync needed — all apps query the same registry table

## Backfill Strategy

### Object Inventory (Current State)

| Schema | Type | Count | Owner |
|--------|------|-------|-------|
| `public` | tables | 64 | hmcs |
| `hmbi` | tables | 16 | hmbi |
| `hm_core` | tables | 13 | shared |
| `training` | tables | 11 | training |
| `wa_intel` | tables | 11 | wa_intel |
| `public` | functions | ~80 custom | mixed (hmcs + hmbi) |
| `hmbi` | functions | 5 | hmbi |
| - | cron_jobs | 3 | mixed |
| - | edge_functions | 13 | mixed |

### Backfill Approach
1. Auto-register all tables by schema (schema → owner mapping)
2. Auto-register all functions by schema
3. Manually register cron jobs (3 items)
4. Manually register edge functions (13 items)
5. Manually classify `public` functions that belong to HMBI (e.g., `hmbi_insert_*`)

## Security Considerations
- [ ] Registry table has RLS enabled (read-only for authenticated, write for service_role)
- [ ] No sensitive data in registry (just object names and ownership)
- [ ] Steering rules are advisory (AI follows them, but no database-level enforcement)

## Performance Considerations
- [ ] Registry table is small (<500 rows) — no performance concern
- [ ] Indexed on `(object_type, object_name)` for fast lookups
- [ ] No impact on existing queries or application performance

## Error Handling
| Error Case | Handling Strategy |
|------------|-------------------|
| Object not in registry | AI must ask user before proceeding |
| Owner mismatch | AI must refuse and explain which app owns it |
| Registry table missing | AI falls back to naming convention (prefix check) |

## No Feature Flag Needed
This is infrastructure/governance work — no UI changes, no feature flag required.
