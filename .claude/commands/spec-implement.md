Implement the next task for spec $1. Follow this workflow:

## Phase 1: Understand the Spec
1. Read `specs/$1/requirements.md`
2. Read `specs/$1/design.md`
3. Read `specs/$1/tasks.md`
4. Read `CLAUDE.md` for architecture conventions

## Phase 2: Identify Next Task
- Look at tasks.md and identify the next uncompleted task (`- [ ]`)
- If all tasks are done, report that the spec is fully implemented

## Phase 3: Plan
- Create a plan for implementing the identified task
- Present the plan and wait for approval before writing code
- Consider: What files need to change? What existing patterns should be followed? What could go wrong?

## Phase 4: Implement
Follow HMWAIntel conventions:
- Pages go in `src/pages/`, components in `src/components/`
- Types defined in `src/lib/types.ts`
- Supabase access via `supabase.schema('wa_intel').from('table')`
- Auth via `useAuth()` from `src/lib/auth.tsx`
- Styling with TailwindCSS, icons with Lucide React
- Always handle loading states and empty states
- No `any` types — use specific interfaces
- Guard array operations with `(array || [])`

For DB changes:
- Verify schema via Supabase MCP before writing queries
- All tables in `wa_intel` schema
- Save migrations to `supabase/migrations/` with timestamp prefix
- Include RLS policies for new tables

## Phase 5: Verify
After implementation:
1. Run `npm run typecheck`
2. Run `npm run build`
3. Run `npm run lint`
Fix any issues found.

**Quality Gates:**
- [ ] No `any` types used
- [ ] All array operations have defensive guards `|| []`
- [ ] Loading and empty states handled
- [ ] wa_intel schema used for all DB queries

## Phase 6: Complete
1. Mark task as complete `[x]` in tasks.md
2. If ALL tasks done, update tasks.md status to `**Status:** Completed`

## Phase 7: Commit
Create a commit with message: `feat: <description of what was implemented>`

## If Issues Occur
- **Missing table/column**: Verify schema with Supabase MCP, check `wa_intel_setup.sql`
- **RLS blocking**: Check policies with `SELECT * FROM pg_policies WHERE schemaname = 'wa_intel'`
- **TypeScript errors**: Run `npm run typecheck` and fix before proceeding
- **Data not showing**: Check if data exists in DB, verify RLS policies, check auth state
