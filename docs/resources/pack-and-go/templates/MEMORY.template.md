# {{PROJECT_NAME}} Project Memory

## Project Identity
- **{{PROJECT_NAME}}** = {{PROJECT_DESCRIPTION}}
- Owner: Hendra, HollyMart retail chain, NTB Indonesia
- Stack: React + TypeScript + Vite + Supabase + TailwindCSS

## Key Architecture Decisions
- Supabase schema: `{{SCHEMA_NAME}}`
- Shared auth via hm_core RBAC (same Supabase instance as all HollyMart projects)
- Spec-driven development workflow

## Conventions
- Conventional commits (feat/fix/refactor/docs/chore)
- Quality gates: typecheck + build + lint before every commit
- Timestamps on all file changes (WITA, HH:MM format)
- Spec folder structure: `specs/{NUMBER}-{name}/` with requirements.md, design.md, tasks.md

## Supabase Rules
- ALWAYS create migration files in `supabase/migrations/`
- NO dollar-quoting (`$$`) — use single-quote quoting
- ALWAYS apply via MCP, then verify + `NOTIFY pgrst, 'reload schema'`
- Always check `.rpc()` error return — Supabase swallows errors silently

## Lessons & Mistakes
<!-- Add lessons as you discover them. Format:
- **[Short title].** [What happened and the fix in 1-2 sentences.]
-->
