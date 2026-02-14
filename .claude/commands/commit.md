Always use haiku model to do commit

Create a commit for the current changes. Follow this exact process:

1. First, run quality checks:
   - `npm run typecheck`
   - `npm run build`
   - `npm run lint`
   If any fail, fix the issues before proceeding.

2. Check `git status` and `git diff` to understand all changes.

3. Check `git log --oneline -5` to see recent commit message style.

4. Draft a commit message following conventional commits:
   - `feat:` — New feature or capability
   - `fix:` — Bug fix
   - `refactor:` — Code restructuring without behavior change
   - `docs:` — Documentation only
   - `chore:` — Build, config, or tooling changes
   - Keep the first line under 72 characters
   - Add detail in the body if the change is complex

5. Stage only relevant files (never stage .env, credentials, or auth_info/ files).

6. Create the commit.

7. Run `git status` after commit to verify success.

Do NOT push unless explicitly asked.
