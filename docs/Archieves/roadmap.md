# HMWAIntel Implementation Roadmap

> **Version:** 1.0.0
> **Created:** 2026-02-13
> **Updated:** 2026-02-13
> **Author:** Hendra + AI Architect
> **Status:** Phase 1 In Progress
> **Purpose:** Phased roadmap for AI project managers and developers to break into specs and execute.

---

## Guiding Principle

**Ship value first, layer control later.**

Start with admin-only access and a thin authorization abstraction. RBAC gets added when non-admin users need access — not before.

---

## Architecture Summary

```
WhatsApp Groups (Baileys listener)
       │
       │  Real-time message capture
       ▼
Supabase (wa_intel schema, messages + classified_items)
       │
       │  Edge Functions (OpenAI classification)
       ▼
Classified Intelligence (tasks, directions, briefings)
       │
       │  Supabase JS client + RLS
       ▼
React Dashboard (HMWAIntel app)
       │
       │  Shared Supabase Auth (hm_core RBAC)
       ▼
Users (admin-only in v0, RBAC when needed)
```

---

## Phase Overview

| Phase | Name | Duration | Outcome | Status |
|-------|------|----------|---------|--------|
| 0 | Foundation | 1 week | Architecture, schema, auth gate | ✅ DONE |
| 1 | Core Features | 2-3 weeks | Listener, classification, dashboard | 🔄 IN PROGRESS |
| 2 | Stabilization | 1-2 weeks | Validation, monitoring, polish | ❌ NOT STARTED |
| 3 | Access Control | 1-2 weeks | RBAC, multi-user access | ❌ NOT STARTED |
| 4 | Extended Features | 3-4 weeks | Advanced analytics, reporting | ❌ NOT STARTED |
| 5 | Advanced | 4-6 weeks | Forecasting, API, integrations | ❌ NOT STARTED |

---

## Phase 0: Foundation (DONE)

> Schema created, auth connected, app skeleton running.

### Spec 0.0: App Architecture — DONE
### Spec 0.1: Schema Setup — DONE
### Spec 0.2: App Skeleton + Auth Gate — DONE

---

## Phase 1: Core Features (IN PROGRESS)

> Listener, classification, dashboard with real data.

### Spec 101: Baileys v7 Upgrade — In Progress
### Spec 201: Classifier Improvements — In Progress
### Spec 202: Topic-Based Classification Redesign — In Progress
### Spec 401: Daily Briefing WA Delivery — In Progress
### Spec 601: Dashboard Enhancements — In Progress
### Spec 701: DB Indexes & Schema Fixes — In Progress

---

## Phase 2: Stabilization

> Make the system reliable and trustworthy.

### Spec 2.1: Data Validation
### Spec 2.2: Monitoring & Alerting
### Spec 2.3: Mobile Polish & UX

---

## Phase 3: Access Control

> Enable multi-user access with RBAC.

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
| Baileys for WA listener | Open-source, no official API needed | Yes (can switch to official API later) |
| OpenAI for classification | Best accuracy for Indonesian + English mixed text | Yes (can switch models) |
| Edge Functions for AI | Keeps API keys server-side, scales with Supabase | Yes |

---

## Success Metrics

| Phase | Metric | Target |
|-------|--------|--------|
| 0 | Project bootstrapped | App loads, auth works |
| 1 | Core features working | Messages captured, classified, displayed |
| 2 | System reliability | >99% uptime, <5min classification lag |
| 3 | Multi-user access | ≥3 users active |

---

## References

| Document | Purpose |
|----------|---------|
| `CLAUDE.md` | Project conventions |
| `SPEC_REGISTRY.md` | Spec tracking |
| `docs/project-context.md` | Background & safety rules |
