# SPEC_REGISTRY — HMSO (Signal operations platform for monitoring, classifying, and surfacing actionable insights)

> Central registry of all feature specifications. **This is the single source of truth for spec status.**
>
> Last updated: 2026-02-13 | Version: 1.0

---

## Summary

| Status | Count | Location |
|--------|-------|----------|
| In Progress | 6 | `.kiro/specs/` |
| Planned | 1 | `.kiro/specs/` |
| Pending | 0 | `.kiro/specs/_pending/` |
| **Complete** | **3** | `.kiro/specs/_completed/` |
| **Total** | **10** | |

---

## Active Specs (In Progress + Planned)

> Spec folders live in `.kiro/specs/`.

### 0xx — Foundation & Discovery

| # | Name | Phase | Status | Description |
|---|------|-------|--------|-------------|
| 001 | HMSO Project Realignment | 0 | In Progress | Realign project to HMSO north star blueprint |

### 1xx — Listener & Infrastructure

| # | Name | Phase | Status | Description |
|---|------|-------|--------|-------------|
| 101 | Baileys v7 Upgrade | 1 | In Progress | Upgrade WhatsApp listener to Baileys v7 |
| 102 | Personal Messages Capture | 1 | In Progress | Capture, classify, and display personal WhatsApp messages |

### 2xx — Classification & AI

| # | Name | Phase | Status | Description |
|---|------|-------|--------|-------------|
| 201 | Classifier Improvements | 1 | In Progress | Improve AI message classification accuracy |
| 202 | Topic-Based Classification Redesign | 1 | In Progress | Redesign classification to use topic-based approach |

### 3xx — Contacts & Groups

| # | Name | Phase | Status | Description |
|---|------|-------|--------|-------------|
| 301 | Group Category Management | 1 | Planned | Categorize WhatsApp groups by relevance with priority-based briefing rendering |

### 4xx — Briefings & Delivery

| # | Name | Phase | Status | Description |
|---|------|-------|--------|-------------|
| 401 | Daily Briefing WA Delivery | 1 | In Progress | Deliver daily briefings via WhatsApp |

### 6xx — Dashboard & UI

| # | Name | Phase | Status | Description |
|---|------|-------|--------|-------------|
| 601 | Dashboard Enhancements | 2 | In Progress | Improve dashboard UX and data visualization |

### 7xx — Database & Performance

| # | Name | Phase | Status | Description |
|---|------|-------|--------|-------------|
| 701 | DB Indexes & Schema Fixes | 0 | In Progress | Add indexes and fix schema issues for performance |

---

## Pending Specs

> Specs that were started or planned but are now on hold, blocked, or deprioritized.
> Spec folders live in `.kiro/specs/_pending/`.

_None currently._

---

## Completed Specs

> Spec folders live in `.kiro/specs/_completed/`. Moved here when all tasks are done and shipped.

| # | Name | Phase | Completed | Description |
|---|------|-------|-----------|-------------|
| 201 | Classifier Improvements | 1 | 2026-02 | Improve AI message classification accuracy |
| 401 | Daily Briefing WA Delivery | 1 | 2026-02 | Deliver daily briefings via WhatsApp |
| 701 | DB Indexes & Schema Fixes | 0 | 2026-02 | Add indexes and fix schema issues for performance |

---

## Domain Ranges

| Range | Domain | Next Available |
|-------|--------|----------------|
| 0xx | Foundation & Discovery | 002 |
| 1xx | Listener & Infrastructure | 103 |
| 2xx | Classification & AI | 203 |
| 3xx | Contacts & Groups | 302 |
| 4xx | Briefings & Delivery | 402 |
| 5xx | Tasks & Directions | 501 |
| 6xx | Dashboard & UI | 602 |
| 7xx | Database & Performance | 702 |

---

## Spec Statuses

| Status | Meaning | Folder |
|--------|---------|--------|
| **In Progress** | Currently being worked on | `specs/` |
| **Planned** | In roadmap, not started yet | `specs/` |
| **Pending** | On hold / blocked / deprioritized | `specs/_pending/` |
| **Complete** | Done and shipped | `specs/_completed/` |

### Status Transitions

```
Planned → In Progress → Complete
              ↓
           Pending → In Progress (when unblocked)
```

---

## Numbering Rules

1. **Domain-based**: Pick the range that matches the feature domain
2. **Sequential**: Use the next available number in that range
3. **Never reuse**: Deleted or superseded specs keep their number forever
4. **Folder format**: `.kiro/specs/{NUMBER}-{name-kebab-case}/`
5. **Completed folder**: `.kiro/specs/_completed/{NUMBER}-{name-kebab-case}/`
6. **Pending folder**: `.kiro/specs/_pending/{NUMBER}-{name-kebab-case}/`

---

## How to Update This Registry

### Creating a new spec
1. Pick next available number from the domain range above
2. Create spec folder in `.kiro/specs/` with status **Planned**
3. Rename Kiro-created folder to include number: `{NUMBER}-{name-kebab-case}/`
4. Add a row to the appropriate Active Specs table above
5. Update the "Next Available" number in Domain Ranges

### Starting a spec
1. Change status to **In Progress** in the Active Specs table

### Completing a spec
1. Move the spec folder: `.kiro/specs/{spec}/ → .kiro/specs/_completed/{spec}/`
2. Remove the row from Active Specs table
3. Add a row to the Completed Specs table with completion date

### Pending a spec
1. Move the spec folder: `.kiro/specs/{spec}/ → .kiro/specs/_pending/{spec}/`
2. Remove the row from Active Specs table
3. Add a row to the Pending Specs table with reason

---

## Version History

| Date | Version | Change |
|------|---------|--------|
| 2026-02-13 | 1.0 | Initial registry (retrofitted from existing specs) |
