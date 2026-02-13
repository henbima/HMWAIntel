Implement the next task for spec $1. Follow this workflow:

## Phase 1: Understand the Spec
1. Find the spec folder — check `specs/$1/` first, then `specs/_pending/$1/` and `specs/_completed/$1/`
   - If found in `_completed/`: report that this spec is already done
   - If found in `_pending/`: ask user if they want to resume it
2. Read `specs/$1/requirements.md`
3. Read `specs/$1/design.md`
4. Read `specs/$1/tasks.md`
5. Read `CLAUDE.md` for architecture conventions

## Phase 2: Identify Next Task
- Look at tasks.md and identify the next uncompleted task (`- [ ]`)
- If all tasks are done, report that the spec is fully implemented
- Note the **Delegate to** level

## Phase 3: Read Pattern Files
Before writing ANY code, read the files referenced in the task:
- Read the **Pattern** file listed in the task
- Read the **Types** pattern file if types need to be defined
- Read any shared components referenced in **Imports**
- This is MANDATORY — never write code without reading the pattern first

## Phase 4: Plan & Delegate
Based on the task's **Delegate to** level:

### If Haiku-level task:
- Delegate to a Haiku subagent with explicit instructions
- Provide the exact file path, pattern file content, imports, and type definitions

### If Sonnet-level task:
- Delegate to a Sonnet subagent with task description, pattern file content, imports, types, and implementation notes

### If Opus-level task:
- Handle directly (do NOT delegate)
- Create a plan, present to user, and wait for approval

## Phase 5: Implement
After receiving subagent output (or writing directly for Opus tasks):
1. Write the file using the Write or Edit tool
2. If the task requires types, write types file first, then implementation

Follow project conventions from CLAUDE.md:
- Modules go in `src/modules/{module_name}/`
- Module structure: `services/`, `components/`, `hooks/`, `types/`, `utils/`
- Supabase access via `supabase.schema('<project_schema>').from('table')`
- Auth via `useAuth()` from `@shared/contexts/AuthContext`
- Styling with TailwindCSS, icons with Lucide React
- Always handle loading states and empty states
- No `any` types — use specific interfaces

For DB changes:
- Verify schema via Supabase MCP before writing queries
- New tables need proper GRANT and RLS policies
- No dollar-quoting in migrations

## Phase 6: Verify
After implementation:
1. Run `npm run typecheck`
2. Run `npm run build`
3. Run `npm run lint`
Fix any issues found.

## Phase 7: Complete
1. Mark task as complete `[x]` in tasks.md
2. If ALL tasks done:
   a. Update tasks.md status to `**Status:** Completed`
   b. Feature flag → `true` in `features.ts`
   c. Verify route exists in parent module
   d. Move spec folder: `git mv specs/$1 specs/_completed/$1`
   e. Update `SPEC_REGISTRY.md`: move row from Active to Completed
   f. Run `/retro` command

## Phase 8: Commit
Create a commit with message: `feat({spec#}): <description>`

## If Issues Occur
- **Missing table/column**: Verify schema with Supabase MCP
- **RLS blocking**: Check `pg_policies`
- **TypeScript errors**: Run `npm run typecheck` and fix
- **Subagent output incorrect**: Fix locally rather than re-delegating

## Parallel Delegation
When multiple tasks in the same phase are independent, launch multiple subagents in parallel.
