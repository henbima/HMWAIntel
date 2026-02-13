# TECHNICAL_DEBT_REGISTRY — {{PROJECT_NAME}} ({{PROJECT_DESCRIPTION}})

> Central registry for tracking technical debt.
>
> Last updated: YYYY-MM-DD | Version: 1.0

---

## Summary

| Priority | Count |
|----------|-------|
| High | 0 |
| Medium | 0 |
| Low | 0 |
| **Total Active** | **0** |
| Resolved | 0 |

---

## Active Debt

_None currently. Items will be added as technical debt is discovered._

<!-- Template for new items:

### TD-001: {Short Title}
- **Priority:** High / Medium / Low
- **Domain:** {domain name}
- **Related Spec:** {Spec number, if any}
- **Discovered:** {YYYY-MM-DD}
- **Impact:** {What breaks or is limited because of this}
- **Current Workaround:** {What we do today}
- **Proper Fix:** {What should be done}
- **Effort:** {Rough estimate: hours / days / weeks}
- **Target:** {When to fix}

-->

---

## Resolved Debt

| ID | Title | Priority | Resolved | Resolution |
|----|-------|----------|----------|------------|

---

## Priority Guide

| Priority | Meaning | Timeline |
|----------|---------|----------|
| **High** | Actively causing bugs, blocking features, or security risk | Fix within 1-2 weeks |
| **Medium** | Not blocking but making development harder | Fix within 1-3 months |
| **Low** | Minor inconvenience, nice-to-have cleanup | Fix when convenient |

### When to Add Debt
- Workarounds written to meet a deadline
- Copy-paste code that should be abstracted
- Known limitations documented in spec implementation
- Hardcoded values that should be configurable
- Missing error handling on critical paths
- Performance issues identified but deferred

### When NOT to Add Debt
- Speculative refactoring ("this might be a problem someday")
- Style preferences ("I'd write this differently")
- Features not yet needed ("we should add caching")

---

## Version History

| Date | Version | Change |
|------|---------|--------|
| YYYY-MM-DD | 1.0 | Initial registry |
