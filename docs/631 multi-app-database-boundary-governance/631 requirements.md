# 631: Multi-App Database Boundary Governance

## Overview
Multiple applications (HMCS, HMBI, and future apps) share a single Supabase database. Without ownership boundaries, AI assistants working on one app can accidentally modify or delete database objects belonging to another app. This spec establishes a self-documenting registry, naming conventions, and AI steering rules to prevent cross-app interference.

## Problem Statement
On Feb 12, 2026, an AI assistant working on the HMBI app applied a migration (`disable_broken_crons`) that deleted 4 cron jobs by ID — including HMCS's healthy `generate-daily-tasks` cron job (job 3). This caused zero daily tasks to be generated for all outlets, directly impacting store operations.

The root cause is systemic: there is no mechanism to identify which app owns which database object. All cron jobs, edge functions, tables, and functions sit in a shared namespace with no ownership markers. Any AI or developer working on any app can see and modify everything.

**User Impact**: Store staff had no tasks assigned for the day. Operations disrupted across all outlets.
**Business Impact**: Task compliance tracking gap. Manual intervention required to restore service.

## Success Criteria
- [ ] All existing database objects (tables, functions, cron jobs, edge functions) are registered with ownership in `hm_core.object_registry`
- [ ] AI steering template exists and is applied to HMCS project
- [ ] Naming convention documented and enforced via steering rules for all future objects
- [ ] Cron jobs renamed with app prefix (3 jobs)
- [ ] Any AI assistant can determine object ownership by querying the registry or reading the name prefix

## Scope

### In Scope
- Create `hm_core.object_registry` table
- Backfill registry with all existing objects and their ownership
- Define naming convention for future database objects
- Rename existing cron jobs with app prefix
- Create universal AI steering template for database boundaries
- Apply steering template to HMCS project
- Create ADR documenting the naming convention
- Add SQL COMMENT ON to critical shared objects

### Out of Scope
- Renaming existing tables (too many references, high risk)
- Renaming existing edge functions (URLs would break)
- Renaming existing PostgreSQL functions (too many references)
- Separate Supabase projects per app
- Database-level permission enforcement (Postgres roles per app)
- Frontend code changes

## User Stories
- As a developer using AI assistants, I want database objects to have clear ownership markers so that the AI doesn't accidentally modify objects belonging to other apps
- As a project owner, I want a single source of truth for which app owns which database object so that I can audit and manage cross-app boundaries
- As an AI assistant, I want to be able to query object ownership before modifying anything so that I never touch objects outside my app's boundary
- As a new app developer, I want a clear naming convention and bootstrap process so that my app's objects are properly isolated from day one

## Dependencies
- **Schema Dependencies**: `hm_core` schema must exist (it does)
- **Database Dependencies**: Access to `cron.job`, `information_schema`, `pg_policies` for backfill
- **No Code Dependencies**: This spec is purely database + documentation

## Constraints
- Legacy objects in `public` schema cannot be renamed (too many code references)
- Edge function slugs cannot be renamed (they're part of the URL)
- Cron job names CAN be renamed (they're just labels, no code references)
- The registry must be queryable by all apps (use `hm_core` schema with appropriate grants)
- Naming convention applies to FUTURE objects only

## Acceptance Criteria

### AC-1: Object Registry
1. `hm_core.object_registry` table exists with columns: `id`, `object_type`, `object_name`, `object_schema`, `owner_app`, `description`, `created_at`
2. Unique constraint on `(object_type, object_name, object_schema)`
3. RLS enabled with read access for all authenticated users
4. All existing tables, functions, cron jobs, and edge functions are registered

### AC-2: Naming Convention
1. ADR document created at `docs/architecture/ADR-006-multi-app-naming-convention.md`
2. Convention covers: tables, functions, cron jobs, edge functions, schemas
3. App prefix registry defined (hmcs, hmbi, hm, etc.)
4. Convention applies to future objects only (legacy exempt)

### AC-3: Cron Job Prefixing
1. Existing cron jobs renamed with app prefix:
   - `generate-daily-tasks` → `hmcs_generate-daily-tasks`
   - `analyze-daily` → `hmbi_analyze-daily`
   - `daily-briefing` → `hmbi_daily-briefing`
2. Cron job functionality unchanged after rename

### AC-4: AI Steering Template
1. Universal steering template created at `.kiro/steering/database-boundary-governance.md`
2. Template includes: mandatory registry check before modify/delete, naming convention rules, forbidden operations list
3. Template is parameterized (app prefix, allowed schemas are variables)
4. Template applied to HMCS project's steering

### AC-5: SQL Comments on Critical Objects
1. `COMMENT ON` applied to all cron jobs
2. `COMMENT ON` applied to critical shared functions
3. Comments include owner app and "DO NOT MODIFY from other apps" warning
