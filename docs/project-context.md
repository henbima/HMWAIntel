# HMSO — Project Context

> **Version:** 2.0 | **Updated:** 2026-02-13 | **Previous:** HMWAIntel v1.0

---

## What Is HMSO?

HollyMart Signal Operations — the organizational nervous system that captures, classifies, and routes actionable signals from every communication channel across HollyMart. Source-agnostic intelligence pipeline that transforms WhatsApp messages, meeting transcripts, and future channels into structured, actionable intelligence.

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Frontend | React + TypeScript + Vite |
| Styling | TailwindCSS |
| Charts | Recharts |
| Icons | Lucide React |
| Database | Supabase (PostgreSQL) |
| Full-Text Search | PostgreSQL tsvector/tsquery (indonesian config) |
| Auth | Supabase Auth (shared HollyMart instance) |
| RBAC | hm_core schema |
| Schema | `wa_intel` (legacy name, may migrate to `hmso` later) |
| WA Listener | Node.js + Baileys (WhatsApp Web API) |
| Meeting Ingestion | n8n (self-hosted on VPS) — Zoom webhook → chunk → summarize |
| AI Classification | OpenAI GPT-4o-mini via Supabase Edge Functions |
| AI Meeting Summaries | OpenRouter (Claude Sonnet / GPT-4o) for premium summarization |
| Workflow Automation | n8n (self-hosted on Biznet NEO Lite VPS) |

---

## Safety Rules

1. **READ-ONLY FIRST** — Never write to production data without explicit approval
2. **Ask before acting** — when in doubt, explain and confirm
3. **Backup before write operations** — always
4. **Test before deploying** — quality gates must pass

---

## Related Systems

| System | Description |
|--------|------------|
| HMSO | Signal Operations — hears the organization (React + Supabase + Baileys + n8n) |
| HMCS | Control System — runs the operation (React + Supabase) |
| HMBI | Business Intelligence — reads the numbers (SQL Server → Supabase dashboards) |
| HMLS | Learning System — trains the people (planned) |

All systems share the same Supabase instance and hm_core auth/RBAC.

### Ecosystem Positioning

HMCS runs operations. HMLS trains people. HMBI reads numbers. HMSO hears the organization. Together they provide complete organizational awareness.

> North Star: `docs/HMSO_BLUEPRINT.md`

---

## Key People

| Person | Role |
|--------|------|
| Hendra | Owner/operator, project lead |

---

## Environment

| Environment | URL |
|-------------|-----|
| Supabase Dashboard | https://supabase.com/dashboard/project/nnzhdjibilebpjgaqkdu |
| Local Dev | http://localhost:5173 |
