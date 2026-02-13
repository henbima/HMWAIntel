Create a spec (feature specification) for: $1

## Phase 0: Pre-Creation Verification (MANDATORY)

Before writing ANY spec files, verify facts:

1. **Read project context:**
   - `CLAUDE.md` (architecture, conventions, DB schema)
   - `wa_intel_setup.sql` (if DB changes needed)

2. **Verify database** (if applicable) — use Supabase MCP:
   ```sql
   SELECT column_name, data_type FROM information_schema.columns
   WHERE table_name = '<TABLE>' AND table_schema = 'wa_intel';
   ```

3. **Verify codebase** — search for existing patterns:
   - Check if similar functionality already exists in `src/pages/` or `src/components/`
   - Check existing hooks, types, and utilities in `src/lib/`
   - Check if there are related Edge Functions in `supabase/functions/`

4. **Document findings** — present to user what you found:
   - What tables exist/need creation
   - What components can be reused
   - Wait for user confirmation before proceeding

## Phase 1: Determine Spec Number

Check existing specs in `specs/` folder and pick the next available number.

Domain ranges for HMWAIntel:
- **100-199**: WhatsApp Listener & Groups
- **200-299**: Message Processing & Classification
- **300-399**: Tasks & Directions
- **400-499**: Briefings & Reports
- **500-599**: Contacts & Group Members
- **600-699**: Dashboard & UI
- **700-799**: Infrastructure & Edge Functions
- **800-899**: Integration & External APIs

## Phase 2: Create Spec Files

Create folder: `specs/{NUMBER}-{spec-name-kebab-case}/`

Create these files:
1. `requirements.md` — What the feature must do (user stories, acceptance criteria)
2. `design.md` — How it will be built (DB changes, component structure, data flow)
3. `tasks.md` — Implementation checklist with checkboxes

### tasks.md Format:
```markdown
# Spec {NUMBER}: {Feature Name} — Tasks

**Status:** Planned

### Phase 1: {Phase Name}

#### - [ ] Task 1.1: {Task Name}
**File:** `exact/path/to/file.ts`

**Acceptance Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2

**Commit:** `feat: description`

## Completion Checklist
- [ ] Run `npm run typecheck` (0 errors)
- [ ] Run `npm run build` (successful)
- [ ] Run `npm run lint` (warnings OK, errors must be fixed)
```

## Phase 3: Quality Check

Present summary to user:
- Spec number and name
- Number of tasks and phases
- Key design decisions
- DB migration needed? (if yes, will go to `supabase/migrations/`)
- Any dependencies or risks

## Phase 4: Commit

```
docs: create spec {NUMBER} for {feature description}
```
