# {{PROJECT_NAME}} — Project Context

> **Version:** 1.0 | **Created:** YYYY-MM-DD

---

## What Is {{PROJECT_NAME}}?

{{PROJECT_DESCRIPTION}}

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Frontend | React + TypeScript + Vite |
| Styling | TailwindCSS |
| Charts | Recharts |
| Icons | Lucide React |
| Database | Supabase (PostgreSQL) |
| Auth | Supabase Auth (shared HollyMart instance) |
| RBAC | hm_core schema |
| Schema | `{{SCHEMA_NAME}}` |

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
| HMBI | POS Business Intelligence (SQL Server → Supabase dashboards) |
| HMCS | HollyMart Compliance System (React + Supabase) |
| HMWAIntel | WhatsApp Intelligence (React + Supabase + Baileys) |
| HMLS | HollyMart Learning System (planned) |

All systems share the same Supabase instance and hm_core auth/RBAC.

---

## Key People

| Person | Role |
|--------|------|
| Hendra | Owner/operator, project lead |

---

## Environment

| Environment | URL |
|-------------|-----|
| Supabase Dashboard | https://supabase.com/dashboard/project/{{SUPABASE_PROJECT_REF}} |
| Local Dev | http://localhost:5173 |
