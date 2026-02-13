Create a pull request for the current branch. Follow this process:

1. Run quality checks first:
   - `npm run typecheck`
   - `npm run build`
   - `npm run lint`
   Fix any issues before proceeding.

2. Gather context:
   - `git status` — check for uncommitted changes
   - `git log main..HEAD --oneline` — see all commits on this branch
   - `git diff main...HEAD --stat` — see all changed files

3. If there are uncommitted changes, commit them first (follow the /commit workflow).

4. Push the branch: `git push -u origin HEAD`

5. Create the PR using `gh pr create` with:
   - A concise title (under 70 characters)
   - A body with this format:
     ```
     ## Summary
     - <bullet points of what changed and why>

     ## Quality Checks
     - [x] TypeScript typecheck passes
     - [x] Production build succeeds
     - [x] ESLint passes

     ## Test Plan
     - <how to verify these changes work>
     ```

6. Return the PR URL.
