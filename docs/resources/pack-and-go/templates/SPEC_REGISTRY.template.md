# SPEC_REGISTRY — {{PROJECT_NAME}} ({{PROJECT_DESCRIPTION}})

> Central registry of all feature specifications. **This is the single source of truth for spec status.**
>
> Last updated: YYYY-MM-DD | Version: 1.0

---

## Summary

| Status | Count | Location |
|--------|-------|----------|
| In Progress | 0 | `specs/` |
| Planned | 0 | `specs/` |
| Pending | 0 | `specs/_pending/` |
| **Complete** | **0** | `specs/_completed/` |
| **Total** | **0** | |

---

## Active Specs (In Progress + Planned)

### 0xx — Foundation & Discovery

| # | Name | Phase | Status | Description |
|---|------|-------|--------|-------------|
| | | | | |

<!-- Add more domain sections as needed. Example domains:
### 1xx — {Domain Name}
### 2xx — {Domain Name}
### 3xx — {Domain Name}
-->

---

## Pending Specs

> Specs that were started or planned but are now on hold, blocked, or deprioritized.
> Spec folders live in `specs/_pending/`.

_None currently._

---

## Completed Specs

> Spec folders live in `specs/_completed/`. Moved here when all tasks are done and shipped.

| # | Name | Phase | Completed | Description |
|---|------|-------|-----------|-------------|

---

## Domain Ranges

| Range | Domain | Next Available |
|-------|--------|----------------|
| 0xx | Foundation & Discovery | 001 |
<!-- Add project-specific domain ranges here -->

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
4. **Folder format**: `specs/{NUMBER}-{name-kebab-case}/`
5. **Completed folder**: `specs/_completed/{NUMBER}-{name-kebab-case}/`
6. **Pending folder**: `specs/_pending/{NUMBER}-{name-kebab-case}/`

---

## How to Update This Registry

### Creating a new spec
1. Pick next available number from the domain range above
2. Create spec folder in `specs/` with status **Planned**
3. Add a row to the appropriate Active Specs table above
4. Update the "Next Available" number in Domain Ranges

### Starting a spec
1. Change status to **In Progress** in the Active Specs table

### Completing a spec
1. Move the spec folder: `specs/{spec}/ → specs/_completed/{spec}/`
2. Remove the row from Active Specs table
3. Add a row to the Completed Specs table with completion date

### Pending a spec
1. Move the spec folder: `specs/{spec}/ → specs/_pending/{spec}/`
2. Remove the row from Active Specs table
3. Add a row to the Pending Specs table with reason

---

## Version History

| Date | Version | Change |
|------|---------|--------|
| YYYY-MM-DD | 1.0 | Initial registry |
