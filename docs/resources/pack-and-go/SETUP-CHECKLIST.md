# Pack & Go — Setup Checklist

> **For:** Hendra (human) | **Updated:** 2026-02-12 12:00 WITA
>
> Use this checklist when starting a new project. Check off each item as you go.

---

## Pre-Setup (One-time, already done)

- [x] HollyMart Supabase instance running (project ref: `nnzhdjibilebpjgaqkdu`)
- [x] hm_core RBAC schema deployed
- [x] Supabase access token available
- [x] Pack & Go kit downloaded/available

---

## Project Setup

### 1. Create Repository
- [ ] Create new folder / git repo for the project
- [ ] Copy `pack-and-go/copy-as-is/` contents to project root
- [ ] Copy `pack-and-go/docs/` guides to project `docs/` folder

### 2. Configure Project Identity
Fill in these values (needed for template files):

| Variable | Your Value |
|----------|-----------|
| Project Name (e.g., HMLS) | _____________ |
| Full Name (e.g., HollyMart Learning System) | _____________ |
| Schema Name (e.g., hmls) | _____________ |
| Route Prefix (e.g., /hmls) | _____________ |
| AI Role Description | _____________ |
| Domain Ranges | _____________ |

### 3. Process Templates
- [ ] Generate `CLAUDE.md` from `CLAUDE.template.md` (replace all `{{PLACEHOLDERS}}`)
- [ ] Generate `SPEC_REGISTRY.md` from template
- [ ] Generate `TECHNICAL_DEBT_REGISTRY.md` from template
- [ ] Generate `docs/roadmap.md` from template
- [ ] Generate `docs/project-context.md` from template
- [ ] Generate `.env.example` from template
- [ ] Generate `.kiro/settings/mcp.json` from template (add your access token!)
- [ ] Generate `.kiro/steering/database-boundary-governance.md` from template

### 4. Initialize React App
- [ ] Run `npm create vite@latest . -- --template react-ts`
- [ ] Install dependencies: `npm install @supabase/supabase-js react-router-dom recharts lucide-react date-fns`
- [ ] Install dev dependencies: `npm install -D tailwindcss @tailwindcss/vite`
- [ ] Configure Tailwind in `vite.config.ts`
- [ ] Set up path aliases in `tsconfig.json` (@core, @shared, @modules, @config)

### 5. Environment Setup
- [ ] Copy `.env.example` to `.env.local`
- [ ] Fill in `VITE_SUPABASE_URL` (https://nnzhdjibilebpjgaqkdu.supabase.co)
- [ ] Fill in `VITE_SUPABASE_ANON_KEY` (get from Supabase dashboard)
- [ ] Add `.env.local` to `.gitignore`

### 6. Database Schema
- [ ] Create project schema in Supabase (via MCP or dashboard)
- [ ] Register the app in hm_core (app ID, permissions)
- [ ] Register all new objects in `hm_core.object_registry` (schema, tables, functions, cron jobs)
- [ ] Verify registry: `SELECT * FROM hm_core.object_registry WHERE owner_app = '{{SCHEMA_NAME}}'`
- [ ] Create initial tables with RLS
- [ ] Verify with test query

### 7. Auth Setup
- [ ] Create `src/shared/services/supabase.ts` (Supabase client)
- [ ] Create `src/shared/contexts/AuthContext.tsx` (follow reference example)
- [ ] Create login page
- [ ] Test login with existing HollyMart account

### 8. First Commit
- [ ] Run quality checks: `npm run typecheck && npm run build && npm run lint`
- [ ] `git add .`
- [ ] `git commit -m "chore: initialize project with Pack & Go bootstrap kit"`

### 9. AI Memory Setup
- [ ] Create memory directory: `~/.claude/projects/{project-path-slug}/memory/`
- [ ] Generate `MEMORY.md` from template
- [ ] Open Claude Code and verify it reads CLAUDE.md

### 10. Start Building
- [ ] Create first spec: `/create-spec {your first feature}`
- [ ] Follow the roadmap phases

---

## Post-Setup Verification

- [ ] `npm run dev` starts without errors
- [ ] Login works with HollyMart credentials
- [ ] Supabase MCP server connects (test with `/db-check`)
- [ ] Quality gate passes: typecheck + build + lint
- [ ] Claude Code reads CLAUDE.md and understands the project

---

## Notes

- The Supabase access token goes in `.kiro/settings/mcp.json` — never commit this file with real tokens
- Add `.kiro/settings/mcp.json` to `.gitignore` if it contains secrets
- Enable MCP servers one at a time to avoid Claude Code stalling
- Priority order: supabase (essential) → context7 (docs) → playwright (testing)
