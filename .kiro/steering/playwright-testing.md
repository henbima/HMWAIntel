---
inclusion: always
version: 1.0.0
last-updated: 2026-02-14
---

# Playwright Testing Rules — HMSO

> **Why:** On 2026-02-14, an AI assistant tested login on `localhost:5173` which was serving HMBI (a different app), not HMSO. Hendra runs multiple HollyMart apps simultaneously on different ports.

## Multi-App Awareness

Hendra develops multiple HollyMart applications concurrently. Common ports may already be occupied by other apps (HMBI, HMCS, etc.). NEVER assume `localhost:5173` or any default port belongs to HMSO.

## Before Any Playwright Test

1. **Start a dedicated dev server** on a unique port (e.g., `npx vite --port 5199`) from the `HMSO/` directory
2. **Verify the app identity** after navigation — check the page title and branding match "HMSO" or "HollyMart Signal Operations"
3. If the page shows a different app (HMBI, HMCS, etc.) → **STOP immediately**, do NOT proceed with testing

## Mandatory Verification Checklist

After the page loads, confirm ALL of these before interacting:
- Page title contains "HMSO" or "Signal Operations"
- Login page shows "HMSO" or "HollyMart Signal Operations" branding
- After login, sidebar shows HMSO navigation (Overview, Tasks, Directions, Briefings, Groups, DMs, Contacts, Import Chat)

## Port Convention

- Use port `5199` as the default for HMSO Playwright testing
- If `5199` is occupied, increment: `5200`, `5201`, etc.
- Always start the server via `controlPwshProcess` so it can be managed and stopped after testing

## After Testing

- Stop the dev server process when testing is complete
- Clean up any screenshots unless the user wants to keep them

## Test Account

- Email: `hendra@hokkymart.com`
- Password: `Olivia123!`
