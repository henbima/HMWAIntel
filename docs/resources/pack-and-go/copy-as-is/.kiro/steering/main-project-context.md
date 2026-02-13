# Project Context — Main Steering Rules

> Primary project context and rules for all AI interactions. This is the master steering file.
> Mirrors `CLAUDE.md` at project root (used by Claude Code).
> All other steering files extend this one.

---

## Role & Expertise

Refer to `CLAUDE.md` at project root for the AI's role definition and expertise area.

## Who You Are Working With

You are working with Hendra, the owner/operator of HollyMart — a retail grocery chain in Nusa Tenggara Barat, Indonesia (~230 employees, 8+ stores). He is technically capable (manages servers, uses Claude AI, builds systems with React/TypeScript/Supabase) but is NOT a professional developer — guide him clearly, explain decisions, and confirm before making changes.

> Full company context: docs/Hendra_Core_Package/company_brief.md
> Operating philosophy: docs/Hendra_Core_Package/Hendra Operating System v1 (HOS v1).md
> AI governance: docs/Hendra_Core_Package/HENDRA AI GOVERNANCE PROMPT PACK v1.md

---

## CRITICAL SAFETY RULES

1. READ-ONLY FIRST. Never write to, modify, or delete production data without explicit approval.
2. No changes to external systems — we only read from and build alongside external data.
3. Backup before any write operations — if we ever need to write, always back up first.
4. Ask before acting — when in doubt, explain what you want to do and ask Hendra to confirm.

---

## Code Modification Rules

1. Read existing code FIRST — understand what's there before changing
2. Make minimal changes — only add what's needed, don't refactor unrelated code
3. Don't touch working code — if data fetching works, leave it alone
4. Test incrementally — add one piece at a time and verify
5. When something breaks, REVERT — don't try to "fix" by changing more things

---

## Verify Before Changing — "Measure Twice, Cut Once"

1. Check the actual data — query the DB, read the code, inspect the state
2. Discuss with the user — present findings and confirm direction BEFORE implementing
3. Only then implement — once facts are verified and direction is agreed

---

## Communication Style

- Hendra speaks English well but it's not his first language — be clear and avoid jargon
- Show progress step by step — don't dump everything at once
- When presenting options, give a clear recommendation with reasoning
- Use practical examples rather than abstract explanations

---

## Related Steering Files

| Steering File | Domain |
|---------------|--------|
| `database-governance.md` | DB access, changes, migration workflow |
| `supabase-migration-standards.md` | Migration file format, MCP compatibility |
| `debugging-methodology.md` | Infrastructure-first debugging framework |
| `implementation-complete-guide.md` | Quality gates & verification |
| `spec-task-tracking.md` | Task checkbox format & completion tracking |
| `hendra-governance.md` | HOS v1 axioms & decision framework |
