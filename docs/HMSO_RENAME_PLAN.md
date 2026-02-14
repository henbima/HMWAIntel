# Plan: Complete Rename from wa_intel/HMWAIntel → hmso/HMSO

## Context

The project was partially rebranded from "HMWAIntel" (WhatsApp Intelligence) to "HMSO" (HollyMart Signal Operations). Documentation is ~90% updated, but the **database schema, code, UI, and GitHub repo still use the old name**. This causes confusion for AI coders and will conflict with other HM apps sharing the same Supabase database.

**Scope:** 600+ references across 115 files. Database schema rename is the highest-risk change.

**Decisions:**
- Rename DB schema `wa_intel` → `hmso` ✅
- Keep WhatsApp column names (`wa_jid`, `wa_group_id`, etc.) — they describe actual WA data ✅
- Hendra will rename GitHub repo manually ✅

---

## Phase 1: Database Migration File

Create `supabase/migrations/20260214220000_rename_wa_intel_to_hmso.sql`:

1. `ALTER SCHEMA wa_intel RENAME TO hmso` — all objects move atomically
2. Update PostgREST: `ALTER ROLE authenticator SET pgrst.db_schemas TO '..., hmso'`
3. `NOTIFY pgrst, 'reload config'`
4. Recreate functions with updated schema-qualified references:
   - `hmso.get_groups_with_today_stats()` — replace all `wa_intel.table` → `hmso.table` in body
   - Rename `wa_intel__search_messages` → `search_messages`
5. Recreate views: `overdue_tasks`, `today_summary` — update schema refs in body
6. Rename cron jobs: unschedule `wa_intel_*`, reschedule as `hmso_*` (same URLs)
7. Update `hm_core.object_registry`: `owner_app = 'hmso'` for all wa_intel entries

**Risk:** Function/view bodies stored as text — `wa_intel.table` refs will break after rename. Must `CREATE OR REPLACE` with corrected refs.

**Note:** I'll still write the migration file for git history, but apply it via Supabase MCP `execute_sql` in chunks. Cron job SQL will use single-quote escaping (no `$$`) to be MCP-compatible.

---

## Phase 2: Backend Code Changes

### Edge Functions (5 files)
Change `schema: "wa_intel"` → `schema: "hmso"`:
- [classify-messages/index.ts](supabase/functions/classify-messages/index.ts) (line 19)
- [daily-briefing/index.ts](supabase/functions/daily-briefing/index.ts) (line 15)
- [analyze-daily/index.ts](supabase/functions/analyze-daily/index.ts) (line 22)
- [detect-task-completion/index.ts](supabase/functions/detect-task-completion/index.ts) (line 15)
- [import-whatsapp-chat/index.ts](supabase/functions/import-whatsapp-chat/index.ts) (all `.schema("wa_intel")` calls)

Also update AI system prompts from "WhatsApp business intelligence" → "organizational intelligence system (HMSO)" where present.

### Listener (4 files)
- [listener/src/supabase.ts](listener/src/supabase.ts): `schema: 'wa_intel'` → `'hmso'`
- [listener/src/briefing-sender.ts](listener/src/briefing-sender.ts): same change
- [listener/package.json](listener/package.json): `"wa-intel-listener"` → `"hmso-listener"`
- [listener/ecosystem.config.cjs](listener/ecosystem.config.cjs): PM2 name `'wa-intel-listener'` → `'hmso-listener'`

---

## Phase 3: Frontend Code Changes

### Schema Client (1 file, ripple to 12 files)
- [src/lib/supabase.ts](src/lib/supabase.ts) line 18: `export const waIntel = supabase.schema('wa_intel')` → `export const hmso = supabase.schema('hmso')`

### All files importing `waIntel` → `hmso` (11 files)
Find-and-replace `waIntel` → `hmso` in:
- [src/hooks/useSupabase.ts](src/hooks/useSupabase.ts)
- [src/components/BriefingSummaryRenderer.tsx](src/components/BriefingSummaryRenderer.tsx)
- [src/components/CategoryManager.tsx](src/components/CategoryManager.tsx)
- [src/services/group-category-service.ts](src/services/group-category-service.ts)
- [src/pages/BriefingsPage.tsx](src/pages/BriefingsPage.tsx)
- [src/pages/ContactsPage.tsx](src/pages/ContactsPage.tsx)
- [src/pages/ConversationsPage.tsx](src/pages/ConversationsPage.tsx)
- [src/pages/DirectionsPage.tsx](src/pages/DirectionsPage.tsx)
- [src/pages/GroupsPage.tsx](src/pages/GroupsPage.tsx)
- [src/pages/OverviewPage.tsx](src/pages/OverviewPage.tsx)
- [src/pages/TasksPage.tsx](src/pages/TasksPage.tsx)

### UI Text (4 files)
- [index.html](index.html): title → `"HMSO — HollyMart Signal Operations"`
- [src/components/Layout.tsx](src/components/Layout.tsx): "WA Intel" → "HMSO", "WA Intelligence" → "Signal Operations"
- [src/pages/LoginPage.tsx](src/pages/LoginPage.tsx): "HollyMart WA Intel" → "HMSO", "WhatsApp Intelligence Dashboard" → "Signal Operations Dashboard"
- [src/pages/OverviewPage.tsx](src/pages/OverviewPage.tsx): "WhatsApp Intelligence overview" → "HMSO overview"

---

## Phase 4: Package & Config

- [package.json](package.json): `"name": "vite-react-typescript-starter"` → `"hmso-dashboard"`
- [listener/package.json](listener/package.json): already covered above
- Rename `wa_intel_setup.sql` → `hmso_setup.sql` and update all internal schema refs

---

## Phase 5: Documentation & Config Files (bulk find-replace)

### Find-replace patterns (applied across all files below)
- `wa_intel` → `hmso` (schema/code contexts — but NOT `wa_jid`, `wa_group_id`, `wa_message_id`, `wa_contact_jid`, `wa_role`)
- `HMWAIntel` → `HMSO` (project name in titles/paths)
- `wa-intel` → `hmso` (kebab-case: package names, server paths)
- `waIntel` → `hmso` (camelCase in code examples within docs)
- `"WhatsApp Intelligence"` → `"Signal Operations"`
- `"WA Intel"` → `"HMSO"`
- `wa_intel_setup.sql` → `hmso_setup.sql`
- `wa-intel-listener` → `hmso-listener`

### 5a. `.kiro/steering/` — ALL 15 files
- `code-quality-complete.md` — schema refs (3 lines)
- `database-boundary-governance.md` — schema/ownership refs (15+ lines)
- `database-essentials.md` — schema refs (18 lines)
- `database-governance-consolidated.md` — schema/governance refs (10+ lines)
- `documentation-standards.md` — `HMWAIntel` path refs (8 lines)
- `hendra-governance.md` — `HMWAIntel` ref (1 line)
- `implementation-complete-guide.md` — schema ref (1 line)
- `kernel.md` — schema, paths, `wa-intel-listener` server path (12+ lines)
- `playwright-testing.md` — `HMWAIntel`, "WA Intel" branding (7 lines)
- `spec-numbering-system.md` — `HMWAIntel` path refs (2 lines)
- `spec-task-tracking.md` — `HMWAIntel` path refs (3 lines)
- `supabase-migration-standards.md` — schema/naming refs (11 lines)
- `supabase-workflow.md` — path + naming refs (2 lines)
- `superior-debugging-methodology.md` — schema/path refs (21 lines)
- `typescript-testing-complete.md` — schema refs (2 lines)

### 5b. `.kiro/prompts/` — 6 of 7 files
- `prm_1_create_spec.md` — paths + schema (19+ lines)
- `prm_1-1_review_spec_requirement.md` — paths + schema (8 lines)
- `prm_2_implement_spec_tasks.md` — paths + schema (17+ lines)
- `prm_3_doublecheck_tasks_isdone.md` — paths + schema (8 lines)
- `prm_4_playwright_test.md` — paths (4 lines)
- `prm_supabase_migrate.md` — schema + paths (6 lines)
- `git.md` — no changes needed

### 5c. `.claude/commands/` — 4 files
- `create-spec.md` — `wa_intel_setup.sql`, schema, `HMWAIntel` (3 lines)
- `db-check.md` — `wa_intel` schema (4 lines)
- `review.md` — `HMWAIntel`, `wa_intel` (4 lines)
- `spec-implement.md` — project name + schema (6 lines)

### 5d. `.kiro/specs/` — 31+ files across spec folders
Active specs (all design.md, requirements.md, tasks.md in each):
- `001-hmso-project-realignment/` (3 files)
- `101-baileys-v7-upgrade/` (1 file: tasks.md)
- `102-personal-messages-capture/` (3 files)
- `202-topic-based-classification-redesign/` (3 files)
- `301-group-category-management/` (3 files)
- `601-dashboard-enhancements/` (3 files)
- `701-db-indexes-and-schema-fixes/` (1 file)

Completed specs:
- `_completed/201-classifier-improvements/` (2 files)
- `_completed/401-daily-briefing-wa-delivery/` (2 files)
- `_completed/701-db-indexes-and-schema-fixes/` (3 files)

Templates (3 files):
- `_templates/tasks.template.md`
- `_templates/requirements.template.md`
- `_templates/design.template.md`

### 5e. Root-level docs
- `README.md` — title + description
- `CLAUDE.md` — remaining `wa_intel` refs (schema name, object ownership)
- `SPEC_REGISTRY.md` — title
- `TECHNICAL_DEBT_REGISTRY.md` — title
- `docs/project-context.md` — project name refs
- `docs/HMSO_BLUEPRINT.md` — verify, may already be updated
- `docs/schema-setup-guide.md` — schema refs
- `docs/shared-auth-setup.md` — "HMWAIntel" in diagrams
- `docs/roadmap.md` — if still has old refs
- `docs/Hendra_Core_Package/company_brief.md` — "HMWAIntel" system ref
- `listener/README.md` — schema + process name refs

### 5f. `.kiro/hooks/` — 1 file
- `spec-numbering-check.kiro.hook` — minimal ref

**Note:** Keep `wa_jid`, `wa_group_id`, `wa_message_id`, `wa_contact_jid`, `wa_role` unchanged — they describe WA-specific data fields, not project branding.

---

## Deployment Order (CRITICAL)

All code changes prepared first, then deployed in this exact sequence.
**I will execute all of these — Hendra only needs to rename the GitHub repo.**

### Tools I'll use:
- **Supabase MCP** (`execute_sql`) — for DB migration (split into chunks, no `$$` dollar-quoting)
- **Supabase MCP** (`deploy_edge_function`) — for all 5 edge functions
- **SSH via Bash** — for listener deployment (SCP files → build → PM2 restart)
  - PEM: `D:\biznet\Hr43GeZ3.pem`, User: `henbima@103.150.92.166`
  - Guide: `.kiro/steering/listener-deployment-guide.md`

### Execution sequence:

**Step 1: Apply DB migration via MCP**
Split into multiple `execute_sql` calls (avoiding `$$` dollar-quoting):
- 1a. `ALTER SCHEMA wa_intel RENAME TO hmso`
- 1b. Update PostgREST config + `NOTIFY pgrst, 'reload config'`
- 1c. Recreate functions with `hmso.table` references
- 1d. Recreate views
- 1e. Unschedule old cron jobs
- 1f. Reschedule cron jobs with `hmso_*` names (use single-quote escaping instead of `$$`)
- 1g. Update `hm_core.object_registry`

**Step 2: Verify DB via MCP**
- `execute_sql`: confirm `hmso` schema exists, tables accessible, PostgREST reloaded

**Step 3: Deploy edge functions via MCP**
- `deploy_edge_function` for: classify-messages, daily-briefing, analyze-daily, detect-task-completion, import-whatsapp-chat

**Step 4: Deploy listener via SSH**
- Stop listener: `pm2 stop wa-intel-listener`
- Rename server directory: `mv ~/wa-intel-listener ~/hmso-listener`
- SCP updated source files to `~/hmso-listener/src/`
- SCP updated `ecosystem.config.cjs` and `package.json`
- Build on server: `cd ~/hmso-listener && npm run build`
- Delete old PM2 entry: `pm2 delete wa-intel-listener`
- Start new: `cd ~/hmso-listener && pm2 start ecosystem.config.cjs`
- Save: `pm2 save`
- Verify: `pm2 status` + `pm2 logs hmso-listener --lines 20 --nostream`

**Step 5: Verify frontend**
- `npm run build` to confirm no TypeScript errors
- Dev server auto-updates

**Downtime:** ~2-5 minutes (between DB migration and listener restart completing).

---

## What Hendra Must Do (only 1 thing)

1. **Rename GitHub repo**: Go to github.com/henbima/HMWAIntel → Settings → rename to `hmso`

After that, I'll run:
```bash
git remote set-url origin https://github.com/henbima/hmso.git
```

---

## Verification

After deployment:
```sql
-- DB: Schema exists
SELECT nspname FROM pg_namespace WHERE nspname = 'hmso';
-- DB: Tables accessible
SELECT COUNT(*) FROM hmso.messages WHERE timestamp >= CURRENT_DATE;
-- DB: Cron jobs renamed
SELECT jobname FROM cron.job WHERE jobname LIKE 'hmso%';
-- DB: Registry updated
SELECT * FROM hm_core.object_registry WHERE owner_app = 'hmso';
```

- Frontend: Load each page, verify data loads, check console for errors
- Listener: `pm2 logs hmso-listener` — confirm messages processing
- Edge functions: Check Supabase dashboard logs

## Rollback

If migration fails: don't deploy code, fix SQL, retry.
If code fails after migration: `ALTER SCHEMA hmso RENAME TO wa_intel` + revert code + redeploy.
