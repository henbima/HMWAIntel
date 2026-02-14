Implement the next task for spec $1. Follow this workflow:

## Agent Delegation (Cost Optimization — MANDATORY)

When running as Opus, you MUST delegate. Do NOT write code or read files directly.
- **Haiku**: Phase 1 (read spec files), Phase 2 (identify next task)
- **Sonnet**: Phase 4 (write code), Phase 5 (run typecheck/build/lint)
- **Opus (you)**: Phase 3 (plan presentation), Phase 6-8 (mark complete, commit, session hygiene), orchestration only

**CRITICAL:** Each task in tasks.md has a `**Delegate:**` tag (Sonnet or Haiku). You MUST use that model for that task. Do NOT override or ignore it.

## Phase 1: Understand the Spec
Read `.kiro/specs/$1/requirements.md`, `design.md`, `tasks.md`, and `CLAUDE.md`.

## Phase 2: Identify Next Task
Find next unchecked task (`- [ ]`) in tasks.md. If all done, report spec fully implemented.

## Phase 3: Plan
Present plan and wait for approval. What files change? What patterns to follow? What risks?

## Phase 4: Implement
Follow conventions from `CLAUDE.md`. For DB changes, verify schema via Supabase MCP first and create migration file.

## Phase 5: Verify
Run `npm run typecheck && npm run build && npm run lint`. Fix any issues.

## Phase 6: Complete
1. Mark task as `[x]` in tasks.md
2. If ALL tasks done, update status to `**Status:** Completed`

## Phase 7: Commit
Message: `feat: <description of what was implemented>`

## Phase 8: Continue
After committing, immediately proceed to the next unchecked task (loop back to Phase 2).
If conversation is getting long, suggest `/compact` before continuing.

## If Issues Occur
- **Missing table/column**: Verify schema with Supabase MCP, check `wa_intel_setup.sql`
- **RLS blocking**: Check policies with `SELECT * FROM pg_policies WHERE schemaname = 'hmso'`
- **TypeScript errors**: Fix before proceeding
- **Data not showing**: Check DB data, RLS policies, auth state