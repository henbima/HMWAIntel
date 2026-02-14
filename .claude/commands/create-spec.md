Create a spec (feature specification) $1

## Agent Delegation (Cost Optimization — MANDATORY)

When running as Opus, you MUST delegate. Do NOT read files or write spec content directly.
- **Haiku**: Phase 0 (codebase search, DB checks), Phase 1 (spec number lookup)
- **Sonnet**: Phase 2 (write requirements.md, design.md, tasks.md)
- **Opus (you)**: Phase 3 (present summary to user), Phase 4 (commit), orchestration only

## Phase 0: Pre-Creation Verification (MANDATORY)

Before writing ANY spec files, verify facts:

1. **Read project context:** `CLAUDE.md`, `wa_intel_setup.sql` (if DB changes needed)
2. **Verify database** (if applicable) — use Supabase MCP to query schema
3. **Verify codebase** — search for existing patterns in `src/`, `supabase/functions/`
4. **Present findings** to user and wait for confirmation before proceeding

## Phase 1: Determine Spec Number

Check `SPEC_REGISTRY.md` for next available number in the appropriate domain range.

## Phase 2: Create Spec Files

Folder: `.kiro/specs/{NUMBER}-{spec-name-kebab-case}/`

Files:
1. {NUMBER}-`requirements.md` — What the feature must do (user stories, acceptance criteria)
2. {NUMBER}-`design.md` — How it will be built (DB changes, component structure, data flow)
3. {NUMBER}-`tasks.md` — Implementation checklist (see format below)

### tasks.md Format:
```markdown
# Spec {NUMBER}: {Feature Name} — Tasks

**Status:** Planned

## Phase 1: {Phase Name}

### - [ ] Task 1.1: {Task Name}
**Delegate:** Sonnet | Haiku
**Files:** `path/to/file.ts`
**AC:** Criterion 1 | Criterion 2 | Criterion 3
**Commit:** `feat: description`

## Completion Checklist
- [ ] `npm run typecheck` (0 errors)
- [ ] `npm run build` (successful)
- [ ] `npm run lint` (warnings OK, errors must be fixed)
```

### Delegate Tag Rules
Every task MUST have a `**Delegate:**` field:
- **Sonnet** — code writing, SQL migrations, component building, analysis
- **Haiku** — file reads, searches, simple lookups, bash commands

## Phase 3: Quality Check

Present summary: spec number, task count, key decisions, dependencies, risks.

## Phase 4: Commit

Message: `docs: create spec {NUMBER} for {feature description}`