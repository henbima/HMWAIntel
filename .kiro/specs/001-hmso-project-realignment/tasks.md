# Spec 001: HMSO Project Realignment — Tasks

**Status:** In Progress
**Created:** 2026-02-13 22:00 WITA

### Phase 1: Spec Evaluation

#### - [x] Task 1.1: Evaluate all 6 active specs against HMSO blueprint
**Delegate to:** Opus
**Files:** `specs/101-*`, `specs/201-*`, `specs/202-*`, `specs/401-*`, `specs/601-*`, `specs/701-*`

**Implementation notes:**
- Read each spec's requirements.md and tasks.md
- Compare against HMSO blueprint (`docs/HMWAINTEL to HMSO_BLUEPRINT.md`)
- For each: recommend Keep, Update, or Delete with rationale
- Identify new capabilities from blueprint that need new specs
- Present findings to Hendra as structured table for approval

**Acceptance Criteria:**
- [x] All 6 specs assessed with Keep/Update/Delete recommendation
- [x] New spec candidates identified from blueprint gaps
- [x] Findings presented to Hendra before any changes

**Results:**
- 101 (Baileys v7): Keep — 201 (Classifier): Keep (completed, moved to _completed/) — 202 (Topic Classification): Keep — 401 (Briefing WA): Keep (completed, moved to _completed/) — 601 (Dashboard): Update (add source_type awareness) — 701 (DB Indexes): Keep (completed, moved to _completed/)
- New spec candidates: Module 6 (Chat with Data), Module 7 (Meeting Ingestion), Module 8 (HMCS Integration), Knowledge Base

---

### Phase 2: Project Identity & Documentation

#### - [x] Task 2.1: Update CLAUDE.md with HMSO identity
**Delegate to:** Opus
**File:** `CLAUDE.md`

**Implementation notes:**
- Change project name → HMSO — HollyMart Signal Operations
- Update role description → source-agnostic signal operations architect
- Add meetings table, source_type, search_vector to database conventions
- Add two-tier AI model strategy (GPT-4o-mini + OpenRouter premium)
- Add HMSO blueprint to Key Documentation table
- Update architecture diagram → multi-source input
- PRESERVE all safety rules, boundary governance, code conventions verbatim

**Acceptance Criteria:**
- [x] Project name updated throughout
- [x] Architecture diagram shows multi-source pipeline
- [x] Two-tier AI strategy documented
- [x] Blueprint referenced as north star
- [x] All safety rules unchanged

**Commit:** `docs(001): update CLAUDE.md with HMSO identity`

---

#### - [x] Task 2.2: Update project-context.md with HMSO identity
**Delegate to:** Sonnet
**File:** `docs/project-context.md`

**Implementation notes:**
- Update one-liner → source-agnostic organizational intelligence system
- Add n8n, OpenRouter, tsvector to tech stack table
- Update Related Systems table (HMWAIntel → HMSO)
- Add ecosystem positioning: HMCS runs operations, HMLS trains people, HMBI reads numbers, HMSO hears the organization

**Acceptance Criteria:**
- [x] One-liner reflects HMSO identity
- [x] Tech stack includes new technologies
- [x] Ecosystem positioning added

**Commit:** `docs(001): update project-context.md with HMSO identity`

---

#### - [x] Task 2.3: Update steering files
**Delegate to:** Sonnet
**Files:** `.kiro/steering/main-project-context.md`, `.kiro/steering/database-boundary-governance.md`

**Implementation notes:**
- Update `main-project-context.md` project description to HMSO
- Update `database-boundary-governance.md` header description (keep `wa_intel` as app identity)
- PRESERVE all governance rules, safety logic, boundary checks unchanged

**Acceptance Criteria:**
- [x] main-project-context.md reflects HMSO
- [x] database-boundary-governance.md description updated
- [x] All governance rules preserved verbatim

**Commit:** `docs(001): update steering files with HMSO identity`

---

### Phase 3: Checkpoint — Review Identity Updates

#### - [x] Task 3.0: Review all documentation changes
**Delegate to:** Opus

**Implementation notes:**
- Verify consistency across CLAUDE.md, project-context.md, steering files
- Ensure no safety rules were accidentally modified
- Ask user if any questions arise

---

### Phase 4: Database Migrations

#### - [x] Task 4.1: Create migration — meetings table
**Delegate to:** Sonnet
**File:** `supabase/migrations/20260215120000_create_meetings_table.sql`

**Implementation notes:**
- CREATE TABLE IF NOT EXISTS hmso.meetings per blueprint Section 5
- Enable RLS, create SELECT policy for authenticated
- GRANT SELECT, INSERT, UPDATE to authenticated and service_role
- GRANT SELECT to anon
- No dollar-quoting, comment header, idempotent

**Acceptance Criteria:**
- [x] Table created with all columns per design
- [x] Indexes on meeting_date DESC and zoom_meeting_id (partial)
- [x] RLS enabled with SELECT policy
- [x] Grants applied
- [x] Migration file follows standards

**Commit:** `feat(001): create hmso.meetings table`

---

#### - [x] Task 4.2: Create migration — multi-source columns on messages
**Delegate to:** Sonnet
**File:** `supabase/migrations/20260215120100_add_multi_source_columns.sql`

**Implementation notes:**
- ALTER TABLE hmso.messages ADD COLUMN source_type TEXT NOT NULL DEFAULT 'whatsapp'
- ALTER TABLE hmso.messages ADD COLUMN meeting_id UUID REFERENCES hmso.meetings(id)
- ALTER TABLE hmso.messages ADD COLUMN meeting_metadata JSONB
- CREATE INDEX on source_type and partial index on meeting_id
- Backfill: UPDATE existing rows SET source_type = 'whatsapp'
- Use column existence check pattern, no dollar-quoting

**Acceptance Criteria:**
- [x] 3 columns added to messages table
- [x] Indexes created
- [x] Existing rows backfilled with source_type='whatsapp'
- [x] Migration file follows standards

**Commit:** `feat(001): add multi-source columns to hmso.messages`

---

#### - [x] Task 4.3: Create migration — full-text search
**Delegate to:** Sonnet
**File:** `supabase/migrations/20260215120200_add_full_text_search.sql`

**Implementation notes:**
- ADD generated search_vector tsvector column using 'indonesian' config on message_text + sender_name
- CREATE GIN INDEX on search_vector
- CREATE FUNCTION hmso.search_messages() with single-quote quoting (NO dollar-quoting)
- Function returns TABLE(id, message_text, sender_name, group_name, timestamp, relevance)

**Acceptance Criteria:**
- [x] search_vector column added
- [x] GIN index created
- [x] Search function created and working
- [x] No dollar-quoting in migration file

**Commit:** `feat(001): add full-text search to hmso.messages`

---

#### - [x] Task 4.4: Create migration — register new objects
**Delegate to:** Sonnet
**File:** `supabase/migrations/20260215120300_register_new_objects.sql`

**Implementation notes:**
- INSERT into hm_core.object_registry for: meetings table, search function, all new indexes
- All entries with owner_app = 'hmso', non-null required fields
- Use ON CONFLICT DO NOTHING for idempotency

**Acceptance Criteria:**
- [x] 2 registerable objects registered (table + function). Indexes not registerable due to check constraint.
- [x] All entries have owner_app = 'hmso'
- [x] Migration is idempotent

**Commit:** `feat(001): register new DB objects in hm_core.object_registry`

---

### Phase 5: Checkpoint — Review Migrations

#### - [x] Task 5.0: Review all migration files
**Delegate to:** Opus

**Implementation notes:**
- Verify all 4 migration files follow standards
- Verify ordering is correct (meetings table → columns → search → registry)
- Ask user if any questions arise

---

### Phase 6: TypeScript Types & Dashboard

#### - [x] Task 6.1: Update TypeScript types
**Delegate to:** Sonnet
**File:** `src/lib/types.ts`
**Pattern:** Follow existing interfaces in same file

**Types to define:**
- Add to `Message`: source_type (string), meeting_id (string | null), meeting_metadata (object | null)
- New `Meeting` interface: id, zoom_meeting_id, title, meeting_date, duration_minutes, participants, total_chunks, executive_summary, raw_transcript, key_decisions, source, metadata, created_at

**Acceptance Criteria:**
- [x] Message interface has new fields
- [x] Meeting interface defined
- [x] `npm run typecheck` passes

**Commit:** `feat(001): add multi-source types to types.ts`

---

#### - [x] Task 6.2: Create SourceBadge component
**Delegate to:** Sonnet
**File:** `src/components/SourceBadge.tsx`
**Pattern:** Follow `src/components/StatusBadge.tsx`
**Imports:**
- `import { MessageSquare, Video, HelpCircle } from 'lucide-react'`

**Implementation notes:**
- Render MessageSquare icon + "WhatsApp" label for source_type='whatsapp'
- Render Video icon + "Meeting" label for source_type='meeting'
- Render HelpCircle icon + source_type value for unknown types
- Handle null/undefined → default to 'whatsapp'
- Small badge style, inline with text

**Acceptance Criteria:**
- [x] Renders correctly for 'whatsapp', 'meeting', and unknown types
- [x] Handles null/undefined gracefully
- [x] Consistent styling with existing badges

**Commit:** `feat(001): create SourceBadge component`

---

#### - [x] Task 6.3: Add source_type display to GroupsPage
**Delegate to:** Sonnet
**File:** `src/pages/GroupsPage.tsx`
**Pattern:** Follow existing message display patterns in same file
**Imports:**
- `import { SourceBadge } from '../components/SourceBadge'`

**Implementation notes:**
- Include source_type in message queries (add to SELECT)
- Render SourceBadge next to messages in message lists
- Ensure backward compatibility — existing WhatsApp data renders correctly

**Acceptance Criteria:**
- [x] source_type included in queries
- [x] SourceBadge displayed next to messages
- [x] Existing data renders correctly (backward compatible)

**Commit:** `feat(001): add source_type display to GroupsPage`

---

### Phase 7: Classification Pipeline

#### - [x] Task 7.1: Document classifier cron status and prepare source_type awareness
**Delegate to:** Opus

**Implementation notes:**
- Query pg_cron to verify classify-messages scheduling status
- Document current cron job status (active/failing/disabled)
- Document any authentication issues found
- Document plan for batch classification of 23k+ accumulated messages
- Update classifier prompt template to add source_type awareness for meeting chunks
- When source_type='meeting': extract MULTIPLE tasks/directions per chunk, weight decisions higher

**Acceptance Criteria:**
- [x] Cron status documented
- [x] Auth issues documented (if any)
- [x] Batch classification plan documented
- [x] Classifier prompt updated with source_type awareness

**Results:**
- **Cron status:** The classify-messages cron job (jobid 9) was REMOVED from cron.job — it no longer exists. Historical runs show it was failing every 15 minutes with `http_header() function does not exist` error (incorrect auth header construction using `http_header()` instead of `net.http_post()` with vault). Last failure: 2026-02-11 01:45 UTC. Likely unscheduled during Spec 631 cleanup on 2026-02-12.
- **Auth issues:** The old cron used `http_header()` function which doesn't exist in Supabase. The working cron jobs (hmcs, hmbi) use `vault.decrypted_secrets` with `net.http_post()` — the correct pattern. The edge function itself (v14) is active and functional, just nothing triggers it.
- **Message backlog:** 21,794 unclassified out of 21,824 total messages. Only 30 were ever classified (single manual run on 2026-02-07).
- **Batch classification plan:** Spec 202 (Topic-Based Classification Redesign) will replace the entire 15-min batch approach with daily topic-based classification. Recommendation: do NOT re-create the old cron job. Instead, proceed with Spec 202 implementation which uses `analyze-daily` edge function with full 24-hour context windows. For the 21k+ backlog, a separate batch job should be created after Spec 202 is complete.
- **Classifier prompt updated:** Added `MEETING_SYSTEM_PROMPT` for source_type='meeting' chunks. Updated `MessageRow` interface with `source_type` field. Updated `fetchUnclassifiedMessages` query to include `source_type`. Updated `buildConversationPrompt` with meeting-specific context. Updated main handler to select prompt based on source_type (meeting → MEETING_SYSTEM_PROMPT, personal → PERSONAL_SYSTEM_PROMPT, group → SYSTEM_PROMPT).

**Commit:** `docs(001): document classifier status and add source_type awareness`

---

### Phase 8: File Structure & Blueprint Integration

#### - [x] Task 8.1: Create placeholder directories
**Delegate to:** Haiku
**Files:** `meetings/README.md`, `chat/README.md`

**Implementation notes:**
- Create `HMSO/meetings/` with README.md explaining Module 7 purpose per blueprint
- Create `HMSO/chat/` with README.md explaining Module 6 purpose per blueprint

**Acceptance Criteria:**
- [x] meetings/ directory created with README
- [x] chat/ directory created with README

**Commit:** `docs(001): create placeholder directories for future modules`

---

#### - [x] Task 8.2: Add blueprint references to documentation
**Delegate to:** Sonnet

**Implementation notes:**
- Verify HMSO blueprint is referenced in CLAUDE.md Key Documentation table (should be done in 2.1)
- Reference blueprint in project-context.md
- Propose renaming `docs/HMWAINTEL to HMSO_BLUEPRINT.md` → `docs/HMSO_BLUEPRINT.md` to Hendra

**Acceptance Criteria:**
- [x] Blueprint referenced in CLAUDE.md
- [x] Blueprint referenced in project-context.md
- [x] Rename proposal presented to Hendra

**Results:**
- CLAUDE.md already references `docs/HMSO_BLUEPRINT.md` as North Star (done in Task 2.1)
- project-context.md already references `docs/HMSO_BLUEPRINT.md` (done in Task 2.2)
- File renamed from `docs/HMWAINTEL to HMSO_BLUEPRINT.md` → `docs/HMSO_BLUEPRINT.md` (approved by Hendra)

**Commit:** `docs(001): add blueprint references across documentation`

---

### Phase 9: Final Verification

#### - [x] Task 9.0: Final quality check
**Delegate to:** Opus

**Implementation notes:**
- Run `npm run typecheck` — must pass with 0 errors
- Run `npm run build` — must succeed
- Verify all migration files follow standards (no dollar-quoting, idempotent, headers, grants)
- Verify no existing functionality is broken

**Results:**
- `npm run typecheck` (tsc --noEmit): PASSED (0 errors)
- `npm run build` (vite build): PASSED (1566 modules, 3.31s)
- All 4 migration files verified: no dollar-quoting, proper headers
- Classifier edge function updated with source_type awareness (local copy only, not deployed — deployment is separate concern)
- Blueprint file renamed to match documentation references

---

## Completion Checklist
- [x] Run `npm run typecheck` (0 errors)
- [x] Run `npm run build` (successful)
- [x] Run `npm run lint` (pre-existing warnings/errors only, no new issues from Spec 001)
- [x] All acceptance criteria from requirements.md met
