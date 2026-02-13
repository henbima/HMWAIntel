# Spec Task Tracking Standards v1.0.0

> How to track task completion in spec files.

---

## Task Checkbox Format

All tasks in `tasks.md` use markdown checkboxes:
- `- [ ]` = Not started
- `- [x]` = Completed

### Rules
1. **Mark tasks as you complete them** — do not batch
2. **Never mark a task complete if quality gates haven't passed**
3. **Update status header** when all tasks are done:
   - `**Status:** Planned` — No tasks started
   - `**Status:** In Progress` — Some tasks complete
   - `**Status:** Completed` — All tasks done

---

## Acceptance Criteria Checkboxes

Each task may have acceptance criteria:
```markdown
#### - [ ] Task 1.1: Create user profile page
**File:** `src/pages/user-profile.tsx`

**Acceptance Criteria:**
- [ ] Page renders with user data
- [ ] Loading state shown while fetching
- [ ] Empty state if no data
- [ ] Edit button opens edit form
```

Mark acceptance criteria checkboxes as you verify each one.

---

## Implementation Reports

When a spec is fully completed, add an implementation report:

```markdown
## Implementation Report

**Completed:** YYYY-MM-DD
**Commits:** list of commit hashes

### Summary
- Brief description of what was built

### Deviations from Design
- Any changes made during implementation that differ from design.md

### Known Issues
- Any issues discovered but not addressed in this spec
```
