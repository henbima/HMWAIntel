Merge the current feature branch into main and push to remote.

## Phase 1: Pre-Flight Checks

1. Check current branch with `git branch --show-current`. If already on `main`, abort.
2. Run quality gate — ALL must pass:
   - `npm run typecheck`
   - `npm run build`
   - `npm run lint`
3. Read `package.json` to get current version.
4. Run `git log --oneline main..HEAD` to show what will be merged.
5. Report to user:
   - Current version
   - Number of commits that will be merged
   - **Ask for confirmation** before proceeding.

## Phase 2: Record Revert Point

1. Run `git log --oneline main -1` to capture main's current HEAD SHA.
2. Save this SHA — it is the **revert point** if anything goes wrong.

## Phase 3: Merge and Push

1. Stash any uncommitted local changes: `git stash push -m "release: pre-merge stash"`
2. Switch to main: `git checkout main`
3. Pull latest: `git pull origin main`
4. Merge with a merge commit:
   ```
   git merge {BRANCH_NAME} --no-ff -m "merge: {BRANCH_NAME} → main

   Revert point: {PREVIOUS_MAIN_SHA}"
   ```
5. Push to remote: `git push origin main`
6. Switch back to previous branch: `git checkout {BRANCH_NAME}`
7. Restore stash if one was created: `git stash pop`

## Phase 4: Post-Release Summary

Print a summary:
```
Release complete: merged {BRANCH_NAME} → main

Revert instructions (if needed):
  git checkout main
  git reset --hard {PREVIOUS_MAIN_SHA}
  git push --force-with-lease origin main
```

## Important Notes
- NEVER force-push to main. Use `--no-ff` merge to preserve history.
- ALWAYS record the revert point before merging.
- If the merge has conflicts, abort and ask the user to resolve them.
- If quality gate fails, fix issues before releasing.
