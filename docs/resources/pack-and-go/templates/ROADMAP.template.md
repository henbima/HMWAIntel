# {{PROJECT_NAME}} Implementation Roadmap

> **Version:** 1.0.0
> **Created:** YYYY-MM-DD
> **Updated:** YYYY-MM-DD
> **Author:** Hendra + AI Architect
> **Status:** Phase 0 Not Started
> **Purpose:** Phased roadmap for AI project managers and developers to break into specs and execute.

---

## Guiding Principle

**Ship value first, layer control later.**

Start with admin-only access and a thin authorization abstraction. RBAC gets added when non-admin users need access — not before.

---

## Architecture Summary

```
[Data Source] (describe your data source)
       │
       │  [Sync mechanism] (daily/real-time/API)
       ▼
Supabase ({{SCHEMA_NAME}} schema, aggregated data)
       │
       │  Supabase JS client + RLS
       ▼
React Dashboard ({{PROJECT_NAME}} app)
       │
       │  Shared Supabase Auth (hm_core RBAC)
       ▼
Users (admin-only in v0, RBAC when needed)
```

---

## Phase Overview

| Phase | Name | Duration | Outcome | Status |
|-------|------|----------|---------|--------|
| 0 | Foundation | 1 week | Architecture, schema, auth gate | ❌ NOT STARTED |
| 1 | Core Features | 2-3 weeks | Primary features with real data | ❌ NOT STARTED |
| 2 | Stabilization | 1-2 weeks | Validation, monitoring, polish | ❌ NOT STARTED |
| 3 | Access Control | 1-2 weeks | RBAC, multi-user access | ❌ NOT STARTED |
| 4 | Extended Features | 3-4 weeks | Advanced features, analytics | ❌ NOT STARTED |
| 5 | Advanced | 4-6 weeks | Forecasting, API, integrations | ❌ NOT STARTED |

---

## Phase 0: Foundation

> **Goal:** Create the project structure, schema, and app skeleton.

### Spec 0.0: App Architecture
- Modular React architecture with strict module boundaries
- Feature flags system
- Path aliases (@core/, @modules/, @shared/, @config/)

### Spec 0.1: Schema Setup
- Create project schema in Supabase
- Core data tables
- RLS policies (admin-only for now)
- Permission grants

### Spec 0.2: App Skeleton + Auth Gate
- Login page (shared HollyMart Supabase auth)
- Auth guard
- App layout shell
- Navigation

---

## Phase 1: Core Features

> **Goal:** Primary features that deliver immediate value.
> **Depends on:** Phase 0 complete.

<!-- Add your project-specific core features here -->

---

## Phase 2: Stabilization

> **Goal:** Make the system reliable and trustworthy.
> **Depends on:** Phase 1 complete, features in daily use.

### Spec 2.1: Data Validation
### Spec 2.2: Monitoring & Alerting
### Spec 2.3: Mobile Polish & UX

---

## Phase 3: Access Control

> **Goal:** Enable multi-user access with RBAC.
> **Depends on:** Phase 2 complete, features trusted and stable.

### Spec 3.1: RBAC Integration (hm_core)
### Spec 3.2: RLS Policies
### Spec 3.3: Admin UI

---

## Dependency Graph

```
Phase 0 (Foundation) ──► Phase 1 (Core) ──► Phase 2 (Stabilization)
                                                     │
                                            Phase 3 (RBAC) ──► Phase 4 (Extended)
                                                                       │
                                                              Phase 5 (Advanced)
```

---

## Decision Log

| Decision | Rationale | Reversible? |
|----------|-----------|-------------|
| | | |

---

## Success Metrics

| Phase | Metric | Target |
|-------|--------|--------|
| 0 | Project bootstrapped | App loads, auth works |
| 1 | Core features working | Daily use by Hendra |
| 2 | System reliability | >99% uptime |
| 3 | Multi-user access | ≥3 users active |

---

## References

| Document | Purpose |
|----------|---------|
| `CLAUDE.md` | Project conventions |
| `SPEC_REGISTRY.md` | Spec tracking |
| `docs/project-context.md` | Background & safety rules |
