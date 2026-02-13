# Implementation Quality Gates & Verification

> Mandatory quality gates for feature implementation.

---

## 5 Mandatory Quality Gates

### Gate 1: Component Integration Verification
Before marking any UI task complete:
- Component renders without errors
- Props are correctly typed (no `any`)
- Event handlers are connected
- State management works (loading, error, success, empty)

### Gate 2: Impact Analysis
Before modifying any existing file:
- List all files that import/use the changed code
- Verify changes don't break existing functionality
- Check for cascading type changes

### Gate 3: Completeness Checklist
For each task, verify:
- [ ] Code compiles (`npm run typecheck`)
- [ ] Build succeeds (`npm run build`)
- [ ] Linter passes (`npm run lint`)
- [ ] All acceptance criteria from spec are met
- [ ] No placeholder/TODO comments left in code
- [ ] No hardcoded values that should be configurable

### Gate 4: Integration Testing
After implementation:
- Test the feature end-to-end in the browser
- Test edge cases (empty data, long strings, many items)
- Test auth states (logged in, logged out, expired session)
- Test error states (network failure, invalid data)

### Gate 5: Code Review Checklist
- [ ] No `any` types
- [ ] Array operations have null guards
- [ ] Auth state properly handled
- [ ] Loading/empty states exist
- [ ] No console.log left (except intentional debug)
- [ ] Follows project naming conventions

---

## 3-Gate AI Safety System

### Before Implementation
- Read the spec files completely
- Read CLAUDE.md for conventions
- Verify database schema matches design
- Present plan to user before coding

### During Implementation
- Follow conventions from CLAUDE.md
- Run typecheck after each significant change
- Don't skip steps or take shortcuts

### After Implementation
- Run full quality suite (typecheck + build + lint)
- Verify against acceptance criteria
- Mark task complete only when ALL gates pass

---

## Prevention of False Verification

NEVER claim something works without evidence:
- "Tested and working" requires actual test execution
- "Build passes" requires `npm run build` output showing success
- "No errors" requires `npm run typecheck` output showing 0 errors
- Screenshots or output logs are preferred evidence

If you cannot verify, say so honestly. "I believe this should work but I wasn't able to verify because [reason]."
