Run the full quality check suite for this project. Execute these commands in order:

1. `npm run typecheck` — TypeScript compilation check
2. `npm run build` — Production build (catches runtime errors like missing references)
3. `npm run lint` — ESLint (warnings are OK, errors must be fixed)

If any step fails:
- Read the error output carefully
- Fix the issues found
- Re-run the failing step to confirm it passes
- Continue to the next step

After all checks pass, report a summary of what was found and fixed.

Do NOT commit any changes — just fix and report.
