# HMWAIntel — Gap Analysis Report

> **Generated:** 2025-07-09
> **Scope:** Full codebase audit against `WA_INTEL_BLUEPRINT.md` (the North Star document)
> **Audited areas:** Database schema, Edge Functions, Baileys Listener, Frontend Dashboard

---

## Executive Summary

The project has a **solid Phase 1 & partial Phase 2/3 foundation** already implemented. The core listen-and-store pipeline (Module 1), AI classification (Module 3), daily briefing (Module 4), and a functional dashboard (Module 5) are all in place. However, there are notable gaps in feature completeness, architectural deviations from the blueprint, missing indexes, security considerations, and Phase 2 features that remain unbuilt.

### Scorecard

| Module | Blueprint Status | Implementation | Gap Level |
|---|---|---|---|
| Module 1 — Baileys Listener | Fully specified | ✅ Implemented | **Low** — minor deviations |
| Module 2 — Database Schema | Fully specified | ✅ Implemented | **Low-Medium** — missing table, missing indexes |
| Module 3 — AI Classifier | Fully specified | ✅ Implemented (Edge Function) | **Medium** — architectural differences |
| Module 4 — Daily Briefing | Fully specified | ✅ Implemented (Edge Function) | **Medium** — no WA delivery |
| Module 5 — Dashboard | Fully specified | ✅ Implemented (Vite+React) | **Medium** — extra pages, missing features |
| Module 6 — RAG Knowledge Base | Phase 2 (deferred) | ❌ Not implemented | **Expected** — Phase 2 |

---

## 1. Database Schema (Module 2)

### 1.1 Tables — Blueprint vs Actual

| Blueprint Table | Exists? | Notes |
|---|---|---|
| `wa_intel.groups` | ✅ Yes (299 rows) | Has extra columns: `listener_id`, `last_synced_at`, `is_starred` (not in blueprint) |
| `wa_intel.contacts` | ✅ Yes (11,928 rows) | Has extra columns: `listener_id`, `last_resolved_at` (not in blueprint) |
| `wa_intel.group_members` | ✅ Yes (15,791 rows) | Has extra column: `listener_id` |
| `wa_intel.messages` | ✅ Yes (19,351 rows) | Has extra columns: `listener_id`, `last_seen_by_listener` |
| `wa_intel.classified_items` | ✅ Yes (30 rows) | Matches blueprint |
| `wa_intel.tasks` | ✅ Yes (1 row) | Matches blueprint |
| `wa_intel.directions` | ✅ Yes (2 rows) | Matches blueprint |
| `wa_intel.daily_briefings` | ✅ Yes (1 row) | Matches blueprint |
| `wa_intel.embeddings` | ❌ No | Phase 2 — expected gap |
| `sync_requests` | ⚠️ In `public` schema | **Not in blueprint.** Listener references it. Should be in `wa_intel` schema per blueprint rules. |

**Extra columns** (`listener_id`, `last_synced_at`, `last_resolved_at`, `last_seen_by_listener`, `is_starred`) are reasonable operational additions not in the original blueprint but add value. No issues.

### 1.2 Missing `sync_requests` Table in `wa_intel` Schema

**Gap:** The `sync_requests` table exists in the `public` schema, but the blueprint explicitly states all wa-intel tables must be in `wa_intel` schema. The listener code queries it via the `wa_intel`-scoped Supabase client — this would only work if the client falls back to `public` or the query path is different.

**Recommendation:** Migrate `sync_requests` to `wa_intel` schema to comply with the blueprint's schema isolation rule.

### 1.3 Indexes — Blueprint vs Actual

| Blueprint Index | Exists? | Notes |
|---|---|---|
| `idx_contacts_jid` | ✅ Yes | |
| `idx_contacts_location` | ✅ Yes | Partial index (`WHERE location IS NOT NULL`) — improvement over blueprint |
| `idx_messages_group_time` | ✅ Yes | |
| `idx_messages_sender` | ❌ **Missing** | Blueprint specifies `idx_messages_sender ON messages(sender_jid)` |
| `idx_messages_from_hendra` | ❌ **Missing** | Blueprint specifies `idx_messages_from_hendra ON messages(is_from_hendra) WHERE is_from_hendra = true` |
| `idx_messages_timestamp` | ✅ Yes | |
| `idx_classified_type` | ❌ **Missing** | Blueprint specifies `idx_classified_type ON classified_items(classification)` |
| `idx_classified_time` | ❌ **Missing** | Blueprint specifies `idx_classified_time ON classified_items(classified_at DESC)` |
| `idx_tasks_status` | ✅ Yes | |
| `idx_tasks_assigned` | ❌ **Missing** | Blueprint specifies `idx_tasks_assigned ON tasks(assigned_to)` |
| `idx_directions_topic` | ❌ **Missing** | Blueprint specifies `idx_directions_topic ON directions(topic)` |
| `idx_directions_valid` | ✅ Yes | |

**Extra indexes** (not in blueprint but present and useful):
- `idx_contacts_active_name`, `idx_contacts_department`
- `idx_messages_group_id`, `idx_messages_contact_id`
- `idx_classified_items_message_id`
- `idx_directions_source_message_id`, `idx_directions_superseded_by`
- `idx_tasks_classified_item_id`, `idx_tasks_completion_message_id`, `idx_tasks_source_message_id`
- `idx_groups_is_starred`

### 1.4 Views

| Blueprint View | Exists? | Notes |
|---|---|---|
| `wa_intel.overdue_tasks` | ✅ Yes | Matches blueprint definition |
| `wa_intel.today_summary` | ✅ Yes | Has extra column `wa_group_id` vs blueprint |

### 1.5 Functions

| Function | In Blueprint? | Notes |
|---|---|---|
| `wa_intel.get_groups_with_today_stats()` | ❌ Not in blueprint | Useful addition. `SECURITY DEFINER` — used by GroupsPage to get stats. |

### 1.6 RLS Policies

All 8 tables have RLS **enabled**. Policies follow a simple pattern: `authenticated` role can SELECT/INSERT/UPDATE based on `auth.uid() IS NOT NULL`. This is a reasonable baseline.

**Gap:** Blueprint mentions RLS as "optional" but the current implementation is permissive — any authenticated user can read/write all data. No row-level or role-based filtering. For a small team this is acceptable, but worth noting.

**Missing:** No DELETE policies on any table — intentional or oversight.

---

## 2. Edge Functions (Module 3 & 4)

### 2.1 WA-Intel Specific Edge Functions

| Function | Blueprint Module | Status | JWT Verify |
|---|---|---|---|
| `classify-messages` | Module 3 (AI Classifier) | ✅ Deployed, v9 | ❌ `false` |
| `daily-briefing` | Module 4 (Daily Briefing) | ✅ Deployed, v5 | ❌ `false` |
| `import-whatsapp-chat` | Not in blueprint | ✅ Deployed, v12 | ❌ `false` |

### 2.2 Non-WA-Intel Edge Functions (on same Supabase project)

These belong to the HMCS system and are **not part of wa-intel**:
- `generate-daily-tasks`, `setup-demo-users`, `user-admin`, `update-task-statuses`, `one-time-tasks`, `auto-approve-one-time-tasks`, `training-reports`, `import-purchase-orders`

### 2.3 `classify-messages` — Detailed Audit

**Matches blueprint:**
- ✅ Classifies into: task, direction, report, question, coordination, noise
- ✅ Extracts: assigned_to, assigned_by, deadline, topic, priority, confidence, summary
- ✅ Auto-creates tasks and directions from classification results
- ✅ Uses `wa_intel` schema
- ✅ Includes sender context (role, location, department, is_leadership) in prompt
- ✅ Handles Hendra flag in prompt context

**Gaps & deviations:**

| Area | Blueprint | Actual | Severity |
|---|---|---|---|
| **AI Model** | Gemini 2.0 Flash (free) or Claude/GPT | OpenAI `gpt-4o-mini` hardcoded | **Medium** — no model abstraction |
| **Model swappability** | "Abstract AI API calls to separate function for easy swap" | Direct OpenAI fetch, not abstracted | **Medium** |
| **Processing mode** | Batch every 15-30 min, or hybrid (Hendra=realtime) | On-demand invocation only | **Low** — acceptable |
| **Task completion detection** | Detect "sudah/selesai/done" replies to auto-close tasks | ❌ **Not implemented** | **High** |
| **Conversation threading** | Not specified in blueprint | ✅ Implemented — groups messages into reply threads | **Positive deviation** |
| **`target_audience` extraction** | Blueprint prompt extracts this for directions | ❌ Not extracted by AI prompt | **Low** |
| **Prompt language** | Blueprint prompt is in Bahasa Indonesia | Actual prompt is in English | **Low** — both work |
| **`deadline_parsed`** | Blueprint has this column | Classifier calls `tryParseDeadline()` but doesn't store in `deadline_parsed` column | **Low** |

### 2.4 `daily-briefing` — Detailed Audit

**Matches blueprint:**
- ✅ Generates daily summary with: new tasks, overdue tasks, completed tasks, new directions
- ✅ Group activity summary
- ✅ Jakarta/WIB timezone handling
- ✅ Stores briefing in `daily_briefings` table
- ✅ Uses `wa_intel` schema

**Gaps:**

| Area | Blueprint | Actual | Severity |
|---|---|---|---|
| **Delivery method** | Send via Baileys to Hendra's WA | ❌ Console/DB only, `sent_via: 'console'` | **High** — core feature missing |
| **Cron schedule** | "Cron setiap jam 7 pagi" | Cron migration exists but no evidence of working schedule | **Medium** |
| **Briefing format** | Emoji-rich format with 📊🆕⚠️✅📝💬 | Plain text with `===` separators | **Low** — cosmetic |
| **Email fallback** | "atau email" mentioned | ❌ Not implemented | **Low** |

### 2.5 `import-whatsapp-chat` — Not in Blueprint

This Edge Function allows importing WhatsApp chat exports (`.txt` files). **Not specified in the blueprint** but is a useful addition for bootstrapping historical data.

**Issue:** The function creates a Supabase client without specifying `wa_intel` schema at the top level — it uses `.schema("wa_intel")` inline on each query, which works but is inconsistent with other functions.

### 2.6 Local vs Deployed Edge Function Sync

Local source files exist in `supabase/functions/` for all 3 wa-intel functions. These may or may not be in sync with deployed versions. The deployed code (fetched via MCP) should be considered authoritative.

---

## 3. Baileys Listener (Module 1)

### 3.1 Overall Assessment

The listener is **well-implemented** and closely follows the blueprint. It's a mature module with good error handling, reconnection logic, and contact resolution.

### 3.2 Matches Blueprint

- ✅ Uses Baileys (`@whiskeysockets/baileys`) for WebSocket connection
- ✅ Persists auth state to filesystem (`auth_info/` folder)
- ✅ Listens `messages.upsert` event
- ✅ Parses: sender JID, push name, group JID, message text, timestamp, message type
- ✅ Resolves contacts by JID lookup, auto-creates if missing
- ✅ Flags `is_from_hendra` based on config
- ✅ Inserts to `wa_intel.messages` with contact_id
- ✅ On startup: fetches group metadata → upserts `groups` + `group_members`
- ✅ Listens `group-participants.update` → updates group_members
- ✅ Auto-reconnect with exponential backoff
- ✅ Read-only (no message sending)
- ✅ Uses `SUPABASE_SERVICE_ROLE_KEY` (bypasses RLS)
- ✅ Uses `wa_intel` schema via client config
- ✅ PM2 ecosystem config present (`ecosystem.config.cjs`)
- ✅ Structured logging with pino

### 3.3 Gaps & Deviations

| Area | Blueprint | Actual | Severity |
|---|---|---|---|
| **Baileys version** | v7.x specified | `^6.7.16` in package.json | **Medium** — blueprint says v7, code uses v6 |
| **Group sync at startup** | "Saat startup: fetch metadata semua grup" | Lazy sync — only syncs on-demand via `sync_requests` polling | **Low** — arguably better design |
| **Contact resolver** | "auto-create contact entry with JID and push name" | ✅ Implemented with cache + name update logic | **Positive** |
| **Log to file** | "Log errors ke console + optional log file" | Console only (pino to stdout) | **Low** |
| **`sync_requests` in `public`** | Not in blueprint | Listener polls `sync_requests` in `public` schema | **Medium** — schema violation |

### 3.4 Listener File Structure — Blueprint vs Actual

| Blueprint | Actual | Notes |
|---|---|---|
| `listener/index.ts` | `listener/src/index.ts` | Nested in `src/` — fine |
| `listener/supabase.ts` | `listener/src/supabase.ts` | ✅ |
| `listener/message-handler.ts` | `listener/src/message-handler.ts` | ✅ |
| — | `listener/src/config.ts` | Extra — good separation |
| — | `listener/src/logger.ts` | Extra — good separation |
| — | `listener/src/contact-resolver.ts` | Extra — good separation |
| — | `listener/src/group-sync.ts` | Extra — good separation |
| — | `listener/src/types/` | Extra — type definitions |
| `listener/auth_info/` | `listener/auth_info/` | ✅ (339 JSON files in auth_info) |

---

## 4. Frontend Dashboard (Module 5)

### 4.1 Tech Stack Deviation

| Blueprint | Actual |
|---|---|
| Next.js + React, deployed to Vercel | **Vite + React** (not Next.js), no Vercel deployment |
| `@supabase/supabase-js` v2 | ✅ Uses v2 via `waIntel = supabase.schema('wa_intel')` |

This is a notable deviation but not necessarily negative — Vite is lighter weight and the dashboard doesn't need SSR.

### 4.2 Pages — Blueprint vs Actual

| Blueprint Page | Actual Page | Status |
|---|---|---|
| `/tasks` — Kanban Board | `TasksPage.tsx` | ✅ Implemented |
| `/directions` — Direction Log | `DirectionsPage.tsx` | ✅ Implemented |
| `/groups` — Group Activity | `GroupsPage.tsx` | ✅ Implemented |
| `/search` — Search (Phase 2) | ❌ Not implemented | Expected — Phase 2 |
| — | `OverviewPage.tsx` (`/`) | Extra — useful dashboard overview |
| — | `BriefingsPage.tsx` (`/briefings`) | Extra — view/generate briefings from UI |
| — | `ContactsPage.tsx` (`/contacts`) | Extra — manage contacts |
| — | `ImportPage.tsx` (`/import`) | Extra — import chat history |
| — | `LoginPage.tsx` (`/login`) | Extra — auth gate |

### 4.3 Feature Gaps in Existing Pages

#### TasksPage (`/tasks`)
| Blueprint Feature | Implemented? |
|---|---|
| 4 columns: New → In Progress → Stuck/Overdue → Done | ⚠️ Has columns but "Stuck" label may differ |
| Drag & drop for status update | ❌ **Missing** — uses dropdown/button clicks |
| Filter by group | ✅ Yes |
| Filter by assigned_to | ✅ Yes |
| Filter by date range | ❌ **Missing** |

#### DirectionsPage (`/directions`)
| Blueprint Feature | Implemented? |
|---|---|
| List all directions, newest first | ✅ Yes |
| Search by keyword/topic | ✅ Yes |
| Tag: topic, target_audience, is_still_valid | ⚠️ topic and is_still_valid shown, target_audience not displayed |
| Detail view: full content + original WA message | ⚠️ Expandable content, but no link to original WA message |

#### GroupsPage (`/groups`)
| Blueprint Feature | Implemented? |
|---|---|
| Overview: all groups, message count today, flagged items | ✅ Yes |
| Click group → see classified messages | ✅ Yes |
| Activity chart: message volume per day per group | ❌ **Missing** — no charts |
| Supabase Realtime subscriptions | ❌ **Missing** — manual refresh only |

### 4.4 Shared Components

| Component | Notes |
|---|---|
| `Layout.tsx` | Sidebar navigation with all routes |
| `StatCard.tsx` | Reusable stat display |
| `EmptyState.tsx` | Empty state placeholder |
| `ThemeToggle.tsx` | Dark/light mode toggle |

### 4.5 Auth Implementation

- Uses Supabase Auth (email/password)
- `AuthProvider` context wraps the app
- Login/register flow implemented
- **No role-based access control** — all authenticated users see everything

---

## 5. Architectural & Cross-Cutting Gaps

### 5.1 Missing Modules / Features

| Feature | Blueprint Reference | Status |
|---|---|---|
| **Task completion detection** | Module 3 — "detect 'sudah/selesai/done' replies" | ❌ Not implemented |
| **Daily briefing WA delivery** | Module 4 — "send via Baileys to Hendra's WA" | ❌ Not implemented |
| **Supabase Realtime** | Module 5 — "Supabase Realtime subscriptions" | ❌ Not implemented |
| **Activity charts** | Module 5 — "Activity chart: message volume per day" | ❌ Not implemented |
| **Drag & drop Kanban** | Module 5 — "Drag & drop untuk update status" | ❌ Not implemented |
| **RAG/Search** | Module 6 — Phase 2 | ❌ Expected gap |
| **Feature flags** | User rules — "gate WIP UI by feature_flags table" | ❌ No feature_flags table or system |
| **Modular structure** | User rules — "every new feature in src/modules/" | ❌ Flat page structure |

### 5.2 AI Model Abstraction

Blueprint: *"Abstract AI API calls to separate function for easy swap (Gemini ↔ Claude ↔ GPT)"*

**Current:** OpenAI API is called directly in the Edge Function with hardcoded model name `gpt-4o-mini`. No abstraction layer exists. Swapping to Gemini or Claude would require rewriting the function.

### 5.3 Cron / Scheduling

- A migration (`20260207231037_schedule_daily_briefing_cron.sql`) exists for scheduling, but there's no evidence of a working cron trigger for:
  - Classifier batch runs (every 15-30 min)
  - Daily briefing generation (7 AM WIB)

### 5.4 `useSupabase.ts` Hook

File exists at `src/hooks/useSupabase.ts` but was not audited in detail. Pages query Supabase directly rather than through a centralized data layer.

---

## 6. Migration Files Audit

9 migration files exist in `supabase/migrations/`:

| Migration | Purpose |
|---|---|
| `20260207115421_add_listener_tracking.sql` | Add listener_id columns |
| `20260207120643_add_sync_requests.sql` | Create sync_requests table |
| `20260207124528_fix_wa_intel_security_issues.sql` | RLS policies |
| `20260207132723_add_groups_with_stats_function.sql` | `get_groups_with_today_stats()` function |
| `20260207133452_add_contacts_indexes.sql` | Contact indexes |
| `20260207142148_add_starred_groups.sql` | `is_starred` column |
| `20260207143126_update_groups_stats_with_total.sql` | Update stats function |
| `20260207231037_schedule_daily_briefing_cron.sql` | Cron for daily briefing |
| `20260207232628_fix_cron_settings.sql` | Fix cron config |

**Note:** The initial schema creation SQL (`wa_intel_setup.sql`) exists at project root but is not in the migrations folder.

---

## 7. Priority Remediation Roadmap

### P0 — Critical (should fix now)

1. **Add missing indexes** — `idx_messages_sender`, `idx_messages_from_hendra`, `idx_classified_type`, `idx_classified_time`, `idx_tasks_assigned`, `idx_directions_topic`
2. **Move `sync_requests` to `wa_intel` schema** — violates blueprint's schema isolation rule
3. **Store `deadline_parsed`** in `classified_items` when classifier parses deadlines

### P1 — High (next sprint)

4. **Task completion detection** — detect reply keywords ("sudah", "selesai", "done") to auto-close tasks
5. **Daily briefing WA delivery** — integrate Baileys sending for Module 4 delivery
6. **AI model abstraction** — extract OpenAI calls into a swappable service layer
7. **Upgrade Baileys to v7** — blueprint specifies v7, currently on v6

### P2 — Medium (backlog)

8. **Drag & drop Kanban** — add `react-beautiful-dnd` or similar library
9. **Activity charts** — add message volume charts to GroupsPage
10. **Supabase Realtime** — subscribe to changes for live dashboard updates
11. **Date range filter** on TasksPage
12. **Feature flags system** — create `feature_flags` table and gating hook
13. **Modular folder structure** — reorganize `src/` into `src/modules/`

### P3 — Low / Phase 2

14. **RAG Knowledge Base** (Module 6) — pgvector, embeddings table, semantic search
15. **Search page** (`/search`) — full-text + semantic search
16. **Role-based access control** — implement proper RBAC in RLS policies
17. **Cron verification** — verify daily briefing and classifier cron jobs are running

---

## 8. Positive Deviations (Improvements Over Blueprint)

These are implementations that go **beyond** the blueprint in a positive way:

1. **Conversation threading in classifier** — groups reply chains before classifying, improving accuracy
2. **Contact caching with name resolution** — efficient JID→contact lookup with lazy name updates
3. **Lazy group sync** — on-demand sync via `sync_requests` instead of blocking startup
4. **Import page** — ability to import historical chat exports
5. **Briefings page** — UI for viewing/generating briefings (not just WA delivery)
6. **Contacts management page** — full CRUD for contacts enrichment
7. **Overview dashboard** — high-level stats page not in blueprint
8. **Extra database indexes** — many useful indexes beyond blueprint specification
9. **Structured logging** — pino logger in listener
10. **Dark mode** — theme toggle in dashboard

---

*End of Gap Analysis Report*
