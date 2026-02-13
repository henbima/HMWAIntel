# Pack & Go — HollyMart Project Bootstrap Kit

> **Version:** 1.1.0 | **Created:** 2026-02-11 22:00 WITA | **Updated:** 2026-02-12 12:00 WITA | **Author:** Hendra + AI Architect
>
> Copy this folder into any new repository. A fresh Claude Code / AI developer reads this file first and bootstraps the entire project automatically.

---

## What This Kit Contains

| Folder | Purpose | Action |
|--------|---------|--------|
| `templates/` | Files needing project-specific customization (`{{PLACEHOLDERS}}`) | Replace placeholders, rename, move to project root |
| `copy-as-is/` | Universal files that work in any project | Copy directly to project root |
| `reference/` | Real examples from HMBI project for pattern reference | Read-only — study, don't copy |
| `docs/` | Setup guides for auth, database, MCP, documentation | Read during setup, then move to project `docs/` |

---

## Bootstrap Procedure (For AI Developer)

### Step 0: Read This File Completely

Do not skip ahead. Read this entire README before taking any action.

### Step 1: Collect Project Variables

Ask the project owner (Hendra) for these values. **Do NOT guess.**

| Variable | Description | Example (HMBI) | Example (HMLS) |
|----------|-------------|-----------------|-----------------|
| `{{PROJECT_NAME}}` | Short project code (uppercase) | `HMBI` | `HMLS` |
| `{{PROJECT_FULL_NAME}}` | Full project name | `HollyMart Business Intelligence` | `HollyMart Learning System` |
| `{{PROJECT_DESCRIPTION}}` | One-line description | `BI dashboards for POS data` | `E-learning platform for staff training` |
| `{{SCHEMA_NAME}}` | Supabase schema (lowercase, no spaces) | `hmbi` | `hmls` |
| `{{ROLE_DESCRIPTION}}` | AI role for CLAUDE.md | `senior BI developer specializing in retail dashboards` | `senior e-learning architect` |
| `{{PAGE_PREFIX}}` | URL route prefix | `/hmbi` | `/hmls` |
| `{{SUPABASE_PROJECT_REF}}` | Supabase project reference ID | `nnzhdjibilebpjgaqkdu` | `nnzhdjibilebpjgaqkdu` (same shared instance) |
| `{{DOMAIN_RANGES}}` | Spec number ranges (see SPEC_REGISTRY template) | `0xx=Foundation, 1xx=Data, 2xx=UI...` | `0xx=Foundation, 1xx=Content, 2xx=UI...` |

### Step 2: Copy Universal Files

Copy everything from `copy-as-is/` to the project root:

```
copy-as-is/.claude/          → .claude/
copy-as-is/.kiro/            → .kiro/
copy-as-is/docs/             → docs/
copy-as-is/specs/            → specs/
copy-as-is/supabase/         → supabase/
```

These files work as-is. No modification needed.

### Step 3: Process Templates

For each file in `templates/`:

1. Read the template file
2. Replace ALL `{{PLACEHOLDER}}` variables with the values from Step 1
3. Save to the target location (noted in each template's header)
4. Remove the `.template` suffix

| Template | Target Location |
|----------|----------------|
| `CLAUDE.template.md` | `CLAUDE.md` (project root) |
| `SPEC_REGISTRY.template.md` | `SPEC_REGISTRY.md` (project root) |
| `TECHNICAL_DEBT_REGISTRY.template.md` | `TECHNICAL_DEBT_REGISTRY.md` (project root) |
| `ROADMAP.template.md` | `docs/roadmap.md` |
| `project-context.template.md` | `docs/project-context.md` |
| `env.example` | `.env.example` (project root) |
| `mcp.json.template` | `.kiro/settings/mcp.json` |
| `MEMORY.template.md` | `~/.claude/projects/{project-path-slug}/memory/MEMORY.md` |
| `database-boundary-governance.template.md` | `.kiro/steering/database-boundary-governance.md` |

### Step 4: Initialize the Project

```bash
# 1. Create React + Vite + TypeScript project (if not already done)
npm create vite@latest . -- --template react-ts

# 2. Install core dependencies
npm install @supabase/supabase-js react-router-dom recharts lucide-react date-fns
npm install -D tailwindcss @tailwindcss/vite

# 3. Set up environment variables
cp .env.example .env.local
# Fill in VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY

# 4. Initialize git (if not already done)
git init
git add .
git commit -m "chore: initialize project with Pack & Go bootstrap kit"
```

### Step 5: Create Project Schema

Follow `docs/schema-setup-guide.md` to:
1. Create the project's Supabase schema (e.g., `hmls`)
2. Set up initial tables
3. Configure RLS policies
4. Grant permissions

### Step 6: Configure Auth

Follow `docs/shared-auth-setup.md` to:
1. Connect to the shared HollyMart Supabase instance
2. Set up AuthContext with hm_core RBAC integration
3. Configure login page

### Step 7: Create First Spec

Use `/create-spec` command to create the first feature specification.

### Step 8: Start Building

You're ready. Follow the spec-driven development workflow:
1. `/create-spec` — Define what to build
2. `/spec-implement {number}` — Build it task by task
3. `/quality` — Check code quality
4. `/commit` — Commit when done
5. `/retro` — Learn from the session

---

## Key Conventions (All Projects)

### Spec-Driven Development
Every feature starts as a spec with 3 files:
- `requirements.md` — What the feature must do
- `design.md` — How it will be built
- `tasks.md` — Implementation checklist with delegation fields

### Quality Gates (Mandatory)
```bash
npm run typecheck    # TypeScript compilation
npm run build        # Production build
npm run lint         # ESLint
```
All three must pass before committing.

### Supabase Schema Convention
- Each project gets its own schema (never use `public` for app data)
- All tables in the project schema: `{{SCHEMA_NAME}}.table_name`
- Service functions access data through schema: `supabase.schema('{{SCHEMA_NAME}}').from('table')`
- RLS policies on every table
- UUID primary keys with `gen_random_uuid()`

### Shared Auth (hm_core)
- All HollyMart projects share one Supabase instance
- Login uses `auth.users` (same credentials across all apps)
- RBAC uses `hm_core` schema (roles, permissions, scoping)
- Each app registers its own permissions in `hm_core.permissions`
- Public wrapper RPCs for PostgREST access: `get_my_hm_role()`, `get_my_menu()`, `check_my_access()`

### AI Delegation Strategy
| Agent | Use For |
|-------|---------|
| **Haiku** | File searches, simple lookups, boilerplate generation |
| **Sonnet** | Service functions, components, SQL queries, code review |
| **Opus** | Architecture decisions, planning, complex cross-module work |

### Commit Convention
```
feat(spec#): description        # New feature
fix(spec#): description         # Bug fix
refactor: description           # Code restructuring
docs: description               # Documentation
chore: description              # Build/config/tooling
```

### File Organization
```
src/
├── core/          # App.tsx, routes.tsx
├── shared/        # Supabase client, AuthContext, shared components
├── modules/       # Feature modules (one per domain)
│   └── {module}/
│       ├── services/    # Data access (Supabase queries)
│       ├── components/  # React components
│       ├── hooks/       # Custom hooks
│       ├── types/       # TypeScript interfaces
│       └── utils/       # Module-specific utilities
└── config/        # Feature flags, environment config
```

---

## Hendra's Operating Philosophy (HOS v1)

### Non-Negotiable Axioms
1. System > People
2. Process > Motivation
3. Rules > Memory
4. Clarity > Speed
5. Repeatability > Talent
6. Written > Verbal
7. Automation > Policing
8. Structure > Kindness
9. Feedback > One-Time Fix
10. Root Cause > Symptom

### Anti-Human-Dependency Check
Reject solutions that rely on:
- People remembering things
- Assumed good behavior without verification
- Constant supervision to work
- High cognitive load for average staff

### Problem Intervention Hierarchy
For recurring issues: **Delete -> Consolidate -> Standardize -> Automate -> Train**

---

## Reading Order for AI Developer

After this README, read in this exact order:

1. `docs/Hendra_Core_Package/company_brief.md` — Understand who HollyMart is
2. `docs/Hendra_Core_Package/Hendra Operating System v1 (HOS v1).md` — Understand the operating philosophy
3. `docs/shared-auth-setup.md` — Understand the shared auth architecture
4. `docs/schema-setup-guide.md` — Understand the database pattern
5. `CLAUDE.md` (after generating from template) — Your project-specific rules
6. `reference/` folder — Study real examples from a working project

---

## Troubleshooting

### Common Issues During Setup

| Issue | Cause | Fix |
|-------|-------|-----|
| MCP server stalls Claude Code | Too many MCP servers enabled at once | Enable one at a time: supabase first, then others |
| PostgREST doesn't see new tables/functions | Schema cache not reloaded | Run `NOTIFY pgrst, 'reload schema'` after migration |
| Supabase migration with `$$` fails | MCP tool can't handle `$` characters | Use single-quote quoting with doubled internal quotes |
| `.rpc()` returns null | PostgREST schema cache stale OR error swallowed | Check `error` return + reload schema |
| Cross-schema function calls fail | Schema not exposed to PostgREST | Create public wrapper functions with `SECURITY DEFINER` |
| RLS blocks all queries | Missing policy or wrong auth context | Check `pg_policies`, verify `auth.uid()` is available |
| `.env` values not loading | Wrong prefix | Vite requires `VITE_` prefix for client-side env vars |

### Lessons Learned (from 30+ specs across 3 projects)

- **Never show placeholder data** — query everything or label as "not queried"
- **Batch large Supabase pushes** — 500 rows per request
- **WITA timezone matters** — use `AT TIME ZONE 'Asia/Makassar'` in Supabase, local date functions in JS
- **Migration file != migration applied** — always execute via MCP after writing the file
- **Apply migration BEFORE deploying code that uses it** — otherwise you get 404s
- **PowerShell `$variables` are eaten by Bash** — use `.ps1` files or Node.js `.cjs` scripts
- **`.js` = ESM in most modern projects** — use `.cjs` for CommonJS temp scripts
- **Shared DB = shared risk** — AI deleted another app's cron job (2026-02-12 incident). Always check `hm_core.object_registry` before any destructive DDL. Never touch objects you don't own.

---

## Version History

| Date | Version | Change |
|------|---------|--------|
| 2026-02-12 | 1.1.0 | Add database boundary governance template (Spec 631 — post-incident) |
| 2026-02-11 | 1.0.0 | Initial kit — extracted from HMAffari/HMBI project |
