# Spec 631: Multi-App Database Boundary Governance — Implementation Report

**Date**: 2026-02-12
**Status**: Complete
**Implemented By**: Claude (Opus 4.6 orchestration + Sonnet delegation)
**Duration**: ~30 minutes

## Executive Summary

Implemented a 4-layer defense system to prevent cross-app interference in the shared HollyMart Supabase database. All 236 existing database objects are now registered with ownership in `hm_core.object_registry`, cron jobs are renamed with app prefixes, and AI steering rules are in place for HMCS. This directly addresses the Feb 12, 2026 incident where an AI assistant working on HMBI accidentally deleted HMCS's daily task generation cron job.

## What Was Implemented

### Phase 1: Object Registry Foundation (Tasks 1.1-1.3)

| Task | Description | Result |
|------|-------------|--------|
| 1.1 | Created `hm_core.object_registry` table | Table with CHECK constraints, RLS, indexes |
| 1.2 | Backfilled registry with tables | 116 tables + 5 schemas registered |
| 1.3 | Backfilled functions, crons, edge functions | 99 functions + 3 cron jobs + 13 edge functions |

**Registry Statistics:**

| Owner App | Tables | Functions | Cron Jobs | Edge Functions | Schemas | Total |
|-----------|--------|-----------|-----------|----------------|---------|-------|
| hmcs | 64 | 76 | 1 | 7 | 1 | 149 |
| hmbi | 16 | 9 | 2 | 6 | 1 | 34 |
| shared | 14 | 4 | 0 | 0 | 1 | 19 |
| training | 11 | 8 | 0 | 0 | 1 | 20 |
| wa_intel | 11 | 2 | 0 | 0 | 1 | 14 |
| **Total** | **116** | **99** | **3** | **13** | **5** | **236** |

Notes:
- `shared` has 14 tables (13 original hm_core + the new `object_registry` itself)
- Functions exclude ~24 pg_trgm extension functions (filtered via `pg_depend`/`pg_extension`)
- Overloaded functions (same name, different signatures) counted once per DISTINCT name

### Phase 2: Cron Job Prefixing (Task 2.1)

| Old Name | New Name | Owner | Schedule | Status |
|----------|----------|-------|----------|--------|
| `generate-daily-tasks` | `hmcs_generate-daily-tasks` | hmcs | `5 16 * * *` | Active |
| `analyze-daily` | `hmbi_analyze-daily` | hmbi | `0 18 * * *` | Active |
| `daily-briefing` | `hmbi_daily-briefing` | hmbi | `0 22 * * *` | Active |

**Note**: Used `cron.unschedule()` + `cron.schedule()` (not direct UPDATE on `cron.job` — permission denied). New job IDs: 17, 18, 19.

### Phase 3: SQL Comments (Tasks 3.1-3.2)

- **19 table comments** applied (critical HMCS tables, shared master data, SOP, reports, retention)
- **8 function comments** applied (critical HMCS functions + shared timezone utilities)
- **3 cron job descriptions** updated in registry with ownership warnings

### Phase 4: Naming Convention (Task 4.1)

- Created `docs/architecture/ADR-006-multi-app-naming-convention.md`
- Covers: tables, functions, cron jobs, edge functions, schemas
- App prefix registry defined (hmcs, hmbi, hm, training, wa_intel)
- Legacy objects explicitly exempted from renaming

### Phase 5: AI Steering (Tasks 5.1-5.2)

- **HMCS steering**: `.kiro/steering/database-boundary-governance.md` (inclusion: always)
- **Portable template**: `docs/reference/steering/database-boundary-template.md`
- Template uses `{APP_PREFIX}`, `{ALLOWED_SCHEMAS}`, `{SHARED_SCHEMAS}` placeholders

### Phase 6: Kernel Update (Task 6.1)

- Updated kernel.md version 2.2.0 → 2.3.0
- Added "Multi-App Database Boundaries" section under Database Governance
- Added `#database-boundary-governance.md` to Invocation Map

## Verification Results

### Registry Completeness
- **0 unregistered tables** (all tables in information_schema have registry entries)
- **3/3 cron jobs** renamed and registered with correct ownership
- **13/13 edge functions** registered with correct ownership

### Quality Checks
- `npm run type-check`: PASS (0 errors)
- `npm run build`: PASS (built in 21s)

## Delegation Strategy

| Task Type | Model | Rationale |
|-----------|-------|-----------|
| DB migrations (Tasks 1.1-3.2) | Opus (direct) | Critical/risky — cron jobs, schema changes |
| ADR-006 document (Task 4.1) | Sonnet (background) | Structured markdown, full content specified |
| Steering templates (Tasks 5.1+5.2) | Sonnet (background) | Structured markdown, full content specified |
| Kernel update (Task 6.1) | Opus (direct) | Integrates with existing kernel, needs context |
| Verification (Tasks 7.1-7.2) | Opus (direct) | DB queries + judgment required |

Doc subagents ran in parallel with DB migration work for time efficiency.

## Migrations Applied

| Timestamp | Migration Name | Description |
|-----------|---------------|-------------|
| * | `create_object_registry` | Table + RLS + indexes |
| * | `backfill_registry_tables` | 116 tables + 5 schemas |
| * | `backfill_registry_functions_crons_edge` | 99 functions + 3 crons + 13 edge functions |
| * | `rename_cron_jobs_with_prefix` | Unschedule old → schedule new names |
| * | `add_ownership_comments_tables` | COMMENT ON 19 critical tables |
| * | `add_ownership_comments_functions` | COMMENT ON 8 functions + update 3 cron descriptions |

## Distribution Instructions for HMBI

To apply database boundary governance to the HMBI project:

1. Copy `docs/reference/steering/database-boundary-template.md` to HMBI's `.kiro/steering/database-boundary-governance.md`
2. Replace placeholders:
   - `{APP_PREFIX}` → `hmbi`
   - `{APP_FULL_NAME}` → `HollyMart Business Intelligence`
   - `{ALLOWED_SCHEMAS}` → `hmbi`
   - `{SHARED_SCHEMAS}` → `hm_core`
   - `{FORBIDDEN_SCHEMAS}` → `public`
3. Add `inclusion: always` front-matter
4. Update HMBI's kernel.md to reference the new steering file

## Files Created/Modified

### New Files
- `docs/architecture/ADR-006-multi-app-naming-convention.md`
- `.kiro/steering/database-boundary-governance.md`
- `docs/reference/steering/database-boundary-template.md`
- `supabase/migrations/*_create_object_registry.sql`
- `supabase/migrations/*_backfill_registry_tables.sql`
- `supabase/migrations/*_backfill_registry_functions_crons_edge.sql`
- `supabase/migrations/*_rename_cron_jobs_with_prefix.sql`
- `supabase/migrations/*_add_ownership_comments_tables.sql`
- `supabase/migrations/*_add_ownership_comments_functions.sql`

### Modified Files
- `.kiro/steering/kernel.md` (v2.2.0 → v2.3.0, added boundary section + invocation)
