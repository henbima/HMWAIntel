# 631: Multi-App Database Boundary Governance - Tasks

**Status:** Complete
**Total Tasks**: 12
**Estimated Effort**: 3-4 hours
**Dependencies**: None

## Pre-Implementation Checklist
- [x] Verify `hm_core` schema exists
- [x] Verify current cron jobs (should be 3: job 14, 15, 16)
- [x] Read current edge function list

## Tasks

### Phase 1: Object Registry Foundation

#### - [x] Task 1.1: Create `hm_core.object_registry` Table
**Description**: Create the registry table with proper constraints, RLS, and indexes.
**Files to Create/Modify**:
  - `supabase/migrations/YYYYMMDDHHMMSS_create_object_registry.sql` - Migration file

**Acceptance Criteria:**
- [x] Table `hm_core.object_registry` exists with all columns from design
- [x] CHECK constraint on `object_type` (table, function, cron_job, edge_function, schema, view, trigger)
- [x] CHECK constraint on `owner_app` (hmcs, hmbi, shared, training, wa_intel)
- [x] UNIQUE constraint on `(object_type, object_name, object_schema)`
- [x] RLS enabled with read policy for all, write policy for service_role
- [x] Indexes created on `(object_type, object_name)` and `(owner_app)`

**Commit:** `feat(spec-631): create hm_core.object_registry table`

#### - [x] Task 1.2: Backfill Registry — Tables
**Description**: Register all existing tables with their ownership based on schema mapping.
**Files to Create/Modify**:
  - `supabase/migrations/YYYYMMDDHHMMSS_backfill_registry_tables.sql` - Migration file

**Acceptance Criteria:**
- [x] All `public` schema tables registered as `owner_app = 'hmcs'`
- [x] All `hmbi` schema tables registered as `owner_app = 'hmbi'`
- [x] All `hm_core` schema tables registered as `owner_app = 'shared'`
- [x] All `training` schema tables registered as `owner_app = 'training'`
- [x] All `wa_intel` schema tables registered as `owner_app = 'wa_intel'`
- [x] Uses `INSERT ... ON CONFLICT DO NOTHING` for idempotency

**Commit:** `feat(spec-631): backfill object registry with existing tables`

#### - [x] Task 1.3: Backfill Registry — Functions, Cron Jobs, Edge Functions
**Description**: Register all existing functions, cron jobs, and edge functions with ownership.
**Files to Create/Modify**:
  - `supabase/migrations/YYYYMMDDHHMMSS_backfill_registry_functions_crons.sql` - Migration file

**Acceptance Criteria:**
- [x] All `public` schema functions registered (hmcs by default, hmbi for `hmbi_insert_*` functions)
- [x] All `hmbi` schema functions registered as `owner_app = 'hmbi'`
- [x] 3 cron jobs registered with correct ownership
- [x] 13 edge functions registered with correct ownership
- [x] HMBI-owned edge functions correctly identified: `import-purchase-orders`, `classify-messages`, `import-whatsapp-chat`, `detect-task-completion`, `daily-briefing`, `analyze-daily`
- [x] HMCS-owned edge functions correctly identified: `generate-daily-tasks`, `setup-demo-users`, `user-admin`, `update-task-statuses`, `one-time-tasks`, `auto-approve-one-time-tasks`, `training-reports`

**Commit:** `feat(spec-631): backfill registry with functions, cron jobs, edge functions`

### Phase 2: Cron Job Prefixing

#### - [x] Task 2.1: Rename Cron Jobs with App Prefix
**Description**: Unschedule existing cron jobs and reschedule with prefixed names. Same schedule, same command.
**Files to Create/Modify**:
  - `supabase/migrations/YYYYMMDDHHMMSS_rename_cron_jobs_with_prefix.sql` - Migration file

**Acceptance Criteria:**
- [x] `generate-daily-tasks` renamed to `hmcs_generate-daily-tasks` (schedule: `5 16 * * *`)
- [x] `analyze-daily` renamed to `hmbi_analyze-daily` (schedule: `0 18 * * *`)
- [x] `daily-briefing` renamed to `hmbi_daily-briefing` (schedule: `0 22 * * *`)
- [x] All 3 jobs active after rename
- [x] Registry updated with new names

**Commit:** `feat(spec-631): rename cron jobs with app prefix`

### Phase 3: SQL Comments on Critical Objects

#### - [x] Task 3.1: Add COMMENT ON to Critical Tables
**Description**: Add ownership comments to critical HMCS tables that other apps must not modify.
**Files to Create/Modify**:
  - `supabase/migrations/YYYYMMDDHHMMSS_add_ownership_comments_tables.sql` - Migration file

**Acceptance Criteria:**
- [x] COMMENT ON applied to: `daily_tasks`, `task_templates`, `task_submissions`, `one_time_tasks`, `one_time_task_submissions`, `users`, `outlets`, `job_roles`, `departments`
- [x] Comments include owner app and warning text
- [x] Comments visible via `\dt+` or `pg_description`

**Commit:** `feat(spec-631): add ownership comments to critical tables`

#### - [x] Task 3.2: Add COMMENT ON to Cron Jobs and Critical Functions
**Description**: Add ownership comments to cron jobs and critical functions.
**Files to Create/Modify**:
  - `supabase/migrations/YYYYMMDDHHMMSS_add_ownership_comments_functions.sql` - Migration file

**Acceptance Criteria:**
- [x] COMMENT ON applied to all 3 cron jobs (via comment on the job name in registry)
- [x] COMMENT ON applied to critical functions: `generate_document_number`, `sync_one_time_task_status_on_review`, `calculate_task_aggregates`, `calculate_user_performance`
- [x] Comments include owner app and warning text

**Commit:** `feat(spec-631): add ownership comments to cron jobs and functions`

### Phase 4: Naming Convention Documentation

#### - [x] Task 4.1: Create ADR-006 Naming Convention Document
**Description**: Document the multi-app naming convention as an Architecture Decision Record.
**Files to Create/Modify**:
  - `docs/architecture/ADR-006-multi-app-naming-convention.md` - New ADR document

**Acceptance Criteria:**
- [x] ADR follows existing ADR format (see ADR-001 through ADR-005)
- [x] Covers: tables, functions, cron jobs, edge functions, schemas
- [x] App prefix registry table included
- [x] Examples for each object type
- [x] Explicitly states legacy objects are exempt
- [x] Decision rationale documented

**Commit:** `docs(spec-631): create ADR-006 multi-app naming convention`

### Phase 5: AI Steering Rules

#### - [x] Task 5.1: Create Universal Database Boundary Steering Template
**Description**: Create the steering file that all projects will use (with project-specific variables).
**Files to Create/Modify**:
  - `.kiro/steering/database-boundary-governance.md` - New steering file for HMCS

**Acceptance Criteria:**
- [x] Contains app identity declaration (`owner_app = 'hmcs'`)
- [x] Contains mandatory registry check rule (query before modify/delete)
- [x] Contains naming convention rules for new objects
- [x] Contains registration requirement after creating new objects
- [x] Contains forbidden operations list
- [x] Contains fallback rule (if registry unavailable, check name prefix)
- [x] Marked as `inclusion: always` in front-matter

**Commit:** `feat(spec-631): create database boundary governance steering`

#### - [x] Task 5.2: Create Portable Steering Template for Other Projects
**Description**: Create a generic version of the steering template that can be copied to HMBI and future projects.
**Files to Create/Modify**:
  - `docs/reference/steering/database-boundary-template.md` - Portable template with placeholder variables

**Acceptance Criteria:**
- [x] Template uses `{APP_PREFIX}`, `{ALLOWED_SCHEMAS}`, `{SHARED_SCHEMAS}` placeholders
- [x] Includes setup instructions for new projects
- [x] Includes example filled-in values for HMCS and HMBI
- [x] Self-contained (no references to HMCS-specific files)

**Commit:** `docs(spec-631): create portable database boundary steering template`

### Phase 6: Kernel Update

#### - [x] Task 6.1: Update kernel.md with Database Boundary Rules
**Description**: Add a section to the HMCS kernel referencing the new governance system.
**Files to Create/Modify**:
  - `.kiro/steering/kernel.md` - Add database boundary section

**Acceptance Criteria:**
- [x] New section "Multi-App Database Boundaries" added to kernel
- [x] References `database-boundary-governance.md` for full rules
- [x] Includes quick-reference: "Before any DROP/ALTER/unschedule, check `hm_core.object_registry`"
- [x] Added to Invocation Map

**Commit:** `feat(spec-631): update kernel with database boundary rules`

### Phase 7: Verification

#### - [x] Task 7.1: Verify Registry Completeness
**Description**: Run verification queries to ensure all objects are registered.
**Files to Create/Modify**:
  - None (verification only)

**Acceptance Criteria:**
- [x] Query: All tables in `information_schema.tables` have matching registry entries
- [x] Query: All cron jobs in `cron.job` have matching registry entries
- [x] Query: Registry count matches expected totals (116 tables, 99 functions, 3 cron jobs, 13 edge functions)
- [x] Query: No orphaned registry entries (objects that no longer exist)

**Commit:** N/A (verification only)

#### - [x] Task 7.2: Create Implementation Report
**Description**: Document what was implemented, verification results, and distribution instructions.
**Files to Create/Modify**:
  - `.kiro/specs/631 multi-app-database-boundary-governance/reports/631-implementation-report-2026-02-12.md`

**Acceptance Criteria:**
- [x] Executive summary (2-3 sentences)
- [x] Registry statistics (total objects registered per app)
- [x] Cron job rename verification
- [x] Steering template distribution instructions for HMBI
- [x] Quality checks: type-check, build pass

**Commit:** `docs(spec-631): create implementation report`

## Post-Implementation Checklist
- [x] All tasks marked complete
- [x] TypeScript type-check passes (`npm run type-check`)
- [x] No console errors in browser
- [x] Registry query returns expected results
- [x] Cron jobs running with new names
- [x] Implementation report created
- [x] SPEC_REGISTRY.md updated

## Completion Checklist
Before marking spec as complete:
- [x] Run `npm run type-check` (0 errors)
- [x] Run `npm run build` (successful)
- [x] Run `npm run lint` (warnings OK, errors must be fixed)
- [x] Update SPEC_REGISTRY.md status to "Completed"

## Verification Commands
```sql
-- Verify registry exists and has data
SELECT owner_app, object_type, COUNT(*)
FROM hm_core.object_registry
GROUP BY owner_app, object_type
ORDER BY owner_app, object_type;

-- Verify cron jobs renamed
SELECT jobid, jobname, schedule, active FROM cron.job ORDER BY jobid;

-- Verify no unregistered tables
SELECT t.table_schema, t.table_name
FROM information_schema.tables t
LEFT JOIN hm_core.object_registry r
  ON r.object_type = 'table' AND r.object_name = t.table_name AND r.object_schema = t.table_schema
WHERE t.table_type = 'BASE TABLE'
  AND t.table_schema IN ('public', 'hmbi', 'hm_core', 'training', 'wa_intel')
  AND r.id IS NULL;
```
