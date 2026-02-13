# CLAUDE.md — {{PROJECT_NAME}} ({{PROJECT_DESCRIPTION}})

## Role & Expertise

{{ROLE_DESCRIPTION}}

## Who You Are Working With

You are working with **Hendra**, the owner/operator of **HollyMart** — a retail grocery chain in Nusa Tenggara Barat, Indonesia (~230 employees, 8+ stores). He is technically capable (manages servers, uses Claude AI, builds systems with React/TypeScript/Supabase) but is NOT a professional developer — guide him clearly, explain decisions, and confirm before making changes.

> Full company context: `docs/Hendra_Core_Package/company_brief.md`
> Operating philosophy: `docs/Hendra_Core_Package/Hendra Operating System v1 (HOS v1).md`
> AI governance: `docs/Hendra_Core_Package/HENDRA AI GOVERNANCE PROMPT PACK v1.md`

---

## Project Overview

**{{PROJECT_NAME}}** — {{PROJECT_FULL_NAME}}. {{PROJECT_DESCRIPTION}}.

- **Database:** Supabase (shared HollyMart instance)
- **Schema:** `{{SCHEMA_NAME}}`
- **Auth:** Shared Supabase Auth + hm_core RBAC

> Full context: `docs/project-context.md`

---

## Priorities (Specs)

> **Full spec tracking:** [`SPEC_REGISTRY.md`](SPEC_REGISTRY.md) — single source of truth for all spec statuses
> **Technical debt:** [`TECHNICAL_DEBT_REGISTRY.md`](TECHNICAL_DEBT_REGISTRY.md)

### Domain Ranges
| Range | Domain | Active | Complete |
|-------|--------|--------|----------|
{{DOMAIN_RANGES}}

### Spec Folder Structure
- `specs/` — active specs (In Progress + Planned)
- `specs/_completed/` — finished specs
- `specs/_pending/` — on hold / blocked specs

---

## CRITICAL SAFETY RULES

1. **READ-ONLY FIRST.** Never write to, modify, or delete production data without explicit approval.
2. **No changes to external systems** — we only read from and build alongside external data.
3. **Backup before any write operations** — if we ever need to write, always back up first.
4. **Ask before acting** — when in doubt, explain what you want to do and ask Hendra to confirm.
5. **MULTI-APP DATABASE BOUNDARY** — This Supabase database is shared with other HollyMart apps. Before ANY `DROP`, `ALTER`, `DELETE`, `TRUNCATE`, or `cron.unschedule()`: query `hm_core.object_registry` to verify ownership is `{{SCHEMA_NAME}}`. NEVER touch objects owned by other apps. See `.kiro/steering/database-boundary-governance.md`.

---

## Technical Notes

- All app data lives in the `{{SCHEMA_NAME}}` Supabase schema (never `public`)
- Shared auth via `hm_core` schema (same across all HollyMart projects)
- React + TypeScript + Vite + TailwindCSS + Recharts + Lucide React

---

## Supabase Migration Workflow

> Detailed standards: `.kiro/steering/supabase-migration-standards.md` and `.kiro/steering/database-governance.md`

### Rules (Non-Negotiable)
1. **Always create a migration file** — Every schema change goes in `supabase/migrations/YYYYMMDDHHMMSS_name.sql`
2. **Apply via Supabase MCP** — Use `execute_sql` or `apply_migration` tool. Never use the dashboard.
3. **NO DOLLAR-QUOTING** — MCP tool cannot handle `$` characters. Use single-quote quoting.
4. **Verify after applying** — Run a test query + `NOTIFY pgrst, 'reload schema'`
5. **Idempotent** — Use `IF NOT EXISTS` / `IF EXISTS` / `CREATE OR REPLACE`

### Migration Checklist
- [ ] File in `supabase/migrations/` with timestamp name
- [ ] Comment header with purpose and date
- [ ] No `$` dollar-quoting anywhere
- [ ] RLS policies for new tables
- [ ] GRANT to `authenticated`, `anon`, `service_role`
- [ ] UUID PKs with `gen_random_uuid()`
- [ ] Applied via MCP and verified

---

## Task Delegation Strategy (Cost Optimization)

When running as Opus, aggressively delegate to cheaper/faster subagents:

### Use Haiku for:
- File searches, grep, glob operations
- Reading and summarizing file contents
- Simple code lookups

### Use Sonnet for:
- Writing components, services, hooks
- Code analysis and review
- SQL queries and migrations

### Keep on Opus only:
- Architecture decisions and planning
- Coordinating multi-step implementations
- Final review and quality checks

---

## Code Modification Rules

1. **Read existing code FIRST** — understand what's there before changing
2. **Make minimal changes** — only add what's needed
3. **Don't touch working code** — if it works, leave it alone
4. **Test incrementally** — add one piece at a time and verify
5. **When something breaks, REVERT** — don't try to "fix" by changing more things

---

## Hendra Operating Philosophy (HOS v1)

### Non-Negotiable Axioms
1. System > People
2. Process > Motivation
3. Rules > Memory
4. Clarity > Speed
5. Repeatability > Talent
6. Written > Verbal
7. Automation > Policing
8. Structure > Kindness
9. Feedback > One-Time Fix
10. Root Cause > Symptom

### Problem Intervention Hierarchy
For recurring issues: **Delete -> Consolidate -> Standardize -> Automate -> Train**

### Anti-Human-Dependency Check
Reject solutions that rely on people remembering things, assumed good behavior, constant supervision, or high cognitive load.

---

## Key Documentation

| Document | Purpose |
|----------|---------|
| `SPEC_REGISTRY.md` | Single source of truth for spec statuses |
| `TECHNICAL_DEBT_REGISTRY.md` | Technical debt tracking |
| `docs/project-context.md` | Project background & safety rules |
| `docs/Hendra_Core_Package/` | HollyMart context & operating philosophy |
| `specs/` | Feature specifications |

---

## Communication Style

- Hendra speaks English well but it's not his first language — be clear and avoid jargon
- Show progress step by step
- When presenting options, give a clear recommendation with reasoning
- Use practical examples rather than abstract explanations
