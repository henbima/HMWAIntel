# Infrastructure-First Debugging Methodology

> Systematic debugging framework. Always check infrastructure before assuming code bugs.

---

## Phase 1: Context Analysis

Before touching any code:
1. **Read the error message carefully** — what exactly is failing?
2. **When did it last work?** — what changed since then?
3. **Is it reproducible?** — always/sometimes/only certain conditions?
4. **What is the scope?** — one page, one feature, entire app?

---

## Phase 2: Dependency Mapping

Trace the data flow from source to display:
1. **Database** — does the data exist? Is it in the expected format?
2. **API/Query** — is the query correct? Is RLS blocking?
3. **Service Layer** — is the data being transformed correctly?
4. **Component** — is the data being passed and rendered correctly?
5. **Browser** — is it a cache, state, or rendering issue?

---

## Phase 3: Infrastructure Verification

Check these BEFORE assuming a code bug:

### Database
- Does the table exist?
- Do the columns match what the code expects?
- Is there data in the table?
- Are RLS policies allowing the query?

### Auth
- Is the user logged in?
- Has the session expired?
- Does the user have the required role?

### Network
- Is the API endpoint responding?
- Are CORS headers correct?
- Is the request payload correct?

### Environment
- Are environment variables set correctly?
- Is the correct database/schema being used?
- Is the dev server running?

---

## Phase 4: Root Cause Isolation

Only after infrastructure checks pass:
1. **Add console.log at key points** — observe actual data
2. **Compare expected vs actual** — at each step of the flow
3. **Binary search** — comment out code to narrow down the issue
4. **Check recent changes** — `git diff` and `git log` for recent modifications

---

## Common Patterns

### "Data not showing"
1. Check: Does data exist in DB?
2. Check: Is RLS policy allowing read?
3. Check: Is the query using the correct schema?
4. Check: Is the component receiving the data?
5. Check: Is the component rendering the data?

### "Feature stopped working"
1. Check: `git log` — what changed recently?
2. Check: Is auth session still valid?
3. Check: Did a deployment change environment variables?
4. Check: Is it a browser cache issue? (hard refresh)

### "TypeScript errors after changes"
1. Run `npm run typecheck` to see all errors
2. Check if a type definition changed
3. Check if imports are correct
4. Don't fix types by adding `any` — find the actual mismatch

---

## Anti-Patterns (DO NOT DO)

- Don't guess — verify with data
- Don't change multiple things at once — isolate variables
- Don't add `any` types to "fix" errors — find the real type
- Don't restart the server as first action — understand the error first
- Don't delete and recreate — understand why it broke
