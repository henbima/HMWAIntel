Create a spec (feature specification) for: $1

## Phase 0: Pre-Creation Verification (MANDATORY)

Before writing ANY spec files, verify facts:

1. **Read project context:**
   - `CLAUDE.md` (architecture, conventions, priorities table)
   - Relevant discovery docs in `discovery/` if DB-related

2. **Verify database** (if applicable) — use Supabase MCP:
   ```sql
   -- Check existing tables in project schema
   SELECT table_name FROM information_schema.tables
   WHERE table_schema = '<PROJECT_SCHEMA>' ORDER BY table_name;

   -- Check columns of a specific table
   SELECT column_name, data_type FROM information_schema.columns
   WHERE table_name = '<TABLE>' AND table_schema = '<PROJECT_SCHEMA>';
   ```

3. **Verify codebase** — search for existing patterns:
   - Check `src/modules/` for existing module structure to follow
   - Check `src/shared/components/` for reusable components
   - Check `src/shared/services/` for shared services
   - Check `src/shared/types/` for shared type definitions

4. **Identify the pattern module** — find the most similar completed spec:
   - Read the pattern module's service, types, and main component to understand the structure

5. **Document findings** — present to user what you found:
   - What tables exist / need creation
   - What components can be reused
   - Which module to use as pattern reference
   - Wait for user confirmation before proceeding

## Phase 1: Determine Spec Number

Check `SPEC_REGISTRY.md` for the next available number in the appropriate domain range.

## Phase 2: Create Spec Files

Create folder: `specs/{NUMBER}-{spec-name-kebab-case}/`

Create these files:
1. `requirements.md` — What the feature must do (user stories, acceptance criteria)
2. `design.md` — How it will be built (DB changes, component structure, data flow)
3. `tasks.md` — Implementation checklist with delegation-ready task format

### requirements.md Header Format:
```markdown
# Spec {NUMBER}: {Feature Name} — Requirements

**Status:** Planned
**Phase:** {phase number}
**Complexity:** Low | Medium | High
**Assignable to:** Haiku / Sonnet / Opus only
**Depends on:** Spec {N} ({name})
**Page:** `/{route}` (if UI spec)
```

Complexity guide for **Assignable to**:
- **Haiku** — Simple file creation following exact template, config changes, adding routes
- **Sonnet** — Standard CRUD, dashboard components following existing patterns, service functions
- **Opus only** — Novel architecture, complex cross-module changes, ambiguous requirements

### tasks.md Format — Delegation-Ready:

Each task MUST include Pattern, Imports, and Types fields so a subagent can implement without searching the codebase.

### Task Writing Rules:
1. **Every task must have a Pattern file** — point to a real existing file
2. **Every task must list Imports** — exact import statements
3. **Types to define** — list every new interface with its fields
4. **One file per task** — don't combine multiple file changes
5. **Delegate to** — mark each task: Haiku (boilerplate), Sonnet (standard), Opus (novel)

## Phase 3: Quality Check

Present summary to user:
- Spec number and name
- Number of tasks and phases
- Key design decisions
- Pattern module being followed
- DB migration needed?
- Task delegation breakdown

## Phase 4: Register in SPEC_REGISTRY

Update `SPEC_REGISTRY.md`:
1. Add a row to the appropriate **Active Specs** domain table with status **Planned**
2. Update the **"Next Available"** number in the Domain Ranges table
3. Update the **Summary** counts

## Phase 5: Commit

```
docs: create spec {NUMBER} for {feature description}
```
