Perform a session retrospective. Review the ENTIRE conversation history and extract lessons learned and approval patterns.

## Part 1: Lessons Learned

Scan the full conversation for:
- **Errors encountered** — build failures, runtime errors, SQL errors, API errors, type errors
- **Gotchas discovered** — unexpected behaviors, edge cases, platform quirks, wrong assumptions
- **Problems solved** — bugs found and fixed, workarounds applied, debugging breakthroughs
- **Failed approaches** — things tried that didn't work and why
- **Data discoveries** — new facts about the database, schema, or business logic

For each finding, write a concise, actionable lesson in this format:
```
- **[Short title].** [What happened and the fix/takeaway in 1-2 sentences.]
```

### Where to save:
1. **MEMORY.md** — Add new lessons to the `## Lessons & Mistakes` section. Deduplicate against existing entries.
2. **Topic-specific files** — If a lesson belongs to a specific domain, create or update a topic file in the memory directory.

### Rules:
- Do NOT duplicate lessons already in MEMORY.md — check before adding
- Keep MEMORY.md under 200 lines total (it gets truncated beyond that)
- Be specific and actionable — "X doesn't work because Y, fix: Z"

## Part 2: Approval Audit

Scan the full conversation for every time you asked for confirmation. Categorize each:

### Category A: Pre-approve for future sessions
Safe, reversible actions that were approved:
- Reading/querying database (read-only)
- Creating/editing files in the project
- Running build/lint/typecheck
- Creating discovery/spec documents
- Updating memory files

### Category B: Keep asking (risky actions)
Actions that should still require confirmation:
- Writing to production database
- Pushing to remote
- Deleting files or branches
- Modifying CI/CD or infrastructure
- Changes to authentication/permissions

## Part 3: Apply Changes

After presenting the findings to the user:
1. Update MEMORY.md with new lessons (after deduplication)
2. Create/update topic memory files if needed
3. Suggest specific permission additions for `settings.local.json`
4. Ask the user to confirm before applying permission changes

## Important
- Be thorough — scan the ENTIRE conversation, not just recent messages
- Group related lessons together
- Prioritize lessons that would save significant time if known upfront
- Do NOT fabricate lessons — only document things that actually happened
