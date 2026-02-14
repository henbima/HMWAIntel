Continue a previously interrupted `/create-spec` session for spec $1.

## Agent Delegation (Cost Optimization — MANDATORY)

When running as Opus, you MUST delegate. Do NOT read files or write spec content directly.
- **Haiku**: Phase 1 (read existing spec files, check what exists)
- **Sonnet**: Phase 3 (write missing spec files)
- **Opus (you)**: Phase 2 (present status), Phase 4 (present summary), Phase 5 (commit), orchestration only

## Phase 1: Assess Current State

Check `.kiro/specs/$1/` for existing files:
- `requirements.md` — exists? complete?
- `design.md` — exists? complete?
- `tasks.md` — exists? complete? has `**Delegate:**` tags per task?

Also check `SPEC_REGISTRY.md` — is this spec registered?

## Phase 2: Present Status

Tell the user:
1. Which files exist and appear complete
2. Which files are missing or incomplete
3. What phase to resume from

Wait for user confirmation before continuing.

## Phase 3: Resume Creation

Pick up where the spec left off:
- If `requirements.md` is missing/incomplete → write it
- If `design.md` is missing/incomplete → write it (re-read requirements.md for context)
- If `tasks.md` is missing/incomplete → write it (re-read requirements.md + design.md for context)
- If tasks.md exists but missing `**Delegate:**` tags → add them

### tasks.md Format (same as create-spec):
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

## Phase 4: Quality Check

Present summary: what was added/fixed, task count, key decisions, dependencies, risks.

## Phase 5: Commit

Message: `docs: continue spec $1 — {what was added/completed}`