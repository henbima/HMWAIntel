Perform a version bump of type "$1" (patch, minor, or major). If "$1" is empty, analyze commits to recommend a bump type.

## Phase 1: Current State

1. Read current version from `package.json`.
2. Run `git log --oneline` since the last version bump commit to see what changed.
3. Report to user:
   - Current version
   - Number of commits since last bump
   - Summary of changes by category

## Phase 2: Determine Bump Type

If "$1" is provided (patch/minor/major), use that.

If "$1" is empty, recommend based on:
- **patch**: Only bug fixes, docs, or minor tweaks
- **minor**: New features, significant enhancements
- **major**: Breaking changes, incompatible API changes, schema overhauls

Present the recommendation and **wait for user confirmation** before proceeding.

## Phase 3: Quality Gate (MANDATORY)

Run these checks — ALL must pass before bumping:
1. `npm run typecheck` — TypeScript compilation
2. `npm run build` — Production build
3. `npm run lint` — ESLint

If any fail, fix the issues and re-run. Do NOT proceed to Phase 4 until all pass.

## Phase 4: Prepare Changelog

1. Analyze all commits since the last version to draft a curated changelog entry.
2. Group changes into: Added, Changed, Fixed, Removed.
3. Present the draft changelog to the user for review.
4. **Wait for user approval or edits** before writing.

## Phase 5: Bump Version

Calculate the new version number and update:

1. **package.json** — Update `"version"` field
2. **CHANGELOG.md** — Create if it doesn't exist, insert the approved changelog entry

## Phase 6: Commit

Create a single commit:
```
chore: bump version to {VERSION}

{One-line summary of what's in this release}
```

Run `git status` after to verify success.

## Important Notes
- Do NOT push unless explicitly asked.
- Do NOT create a git tag — tags are managed separately.
