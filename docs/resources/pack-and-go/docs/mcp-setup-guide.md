# MCP Server Setup Guide

> **Updated:** 2026-02-11 22:00 WITA
>
> How to configure Model Context Protocol (MCP) servers for Claude Code.

---

## What Are MCP Servers?

MCP servers give Claude Code direct access to external tools — Supabase database, documentation libraries, browser automation, etc. They run as background processes that Claude Code communicates with.

---

## Configuration Location

**ONLY configure in:** `.kiro/settings/mcp.json`

**NEVER duplicate in:** `.claude/settings.local.json` (the `enabledMcpjsonServers` key)

Having servers in both places causes Claude Code VS Code extension to crash/stall.

---

## Available Servers

### 1. Supabase MCP (Essential — enable first)

```json
{
  "supabase": {
    "command": "npx",
    "args": [
      "-y",
      "@supabase/mcp-server-supabase@latest",
      "--access-token",
      "YOUR_ACCESS_TOKEN",
      "--project-ref",
      "YOUR_PROJECT_REF"
    ],
    "disabled": false,
    "autoApprove": [
      "execute_sql",
      "apply_migration",
      "list_tables",
      "list_migrations",
      "get_project_url",
      "get_logs",
      "search_docs"
    ]
  }
}
```

**Where to get the access token:**
1. Go to https://supabase.com/dashboard/account/tokens
2. Generate a new access token
3. Paste into the config

**Key tools:**
- `execute_sql` — Run SQL queries directly
- `apply_migration` — Apply migration files
- `list_tables` — List all tables in a schema
- `search_docs` — Search Supabase documentation

### 2. Context7 (Documentation lookup)

```json
{
  "context7": {
    "command": "npx",
    "args": ["-y", "@upstash/context7-mcp"],
    "disabled": true,
    "autoApprove": ["resolve-library-id", "get-library-docs"]
  }
}
```

Provides up-to-date documentation for libraries (React, Supabase, Tailwind, etc.).

### 3. Playwright (Browser testing)

```json
{
  "playwright": {
    "command": "npx",
    "args": ["@playwright/mcp@latest", "--isolated"],
    "disabled": true,
    "autoApprove": [
      "browser_navigate",
      "browser_click",
      "browser_type",
      "browser_snapshot",
      "browser_take_screenshot"
    ]
  }
}
```

Allows Claude Code to control a browser for testing.

### 4. SQL Server (Only if project needs SQL Server access)

```json
{
  "sqlserver": {
    "command": "node",
    "args": ["tools/mcp-sqlserver/index.js"],
    "env": {
      "SQLSERVER_HOST": "192.168.51.100",
      "SQLSERVER_USER": "claude_reader",
      "SQLSERVER_PASSWORD": "${SQLSERVER_PASSWORD}"
    },
    "disabled": true,
    "autoApprove": ["sql_query", "list_databases", "list_tables", "describe_table"]
  }
}
```

---

## Setup Process

### Critical: Enable One at a Time

Enabling all servers simultaneously causes Claude Code to stall. Follow this process:

1. Start with ALL servers `"disabled": true`
2. Enable `supabase` first → test Claude Code responsiveness → confirm it works
3. Enable `context7` → test responsiveness
4. Enable `playwright` → test responsiveness
5. Only enable `sqlserver` if your project needs SQL Server access

### Priority Order

| Priority | Server | When to Enable |
|----------|--------|---------------|
| 1 (Essential) | supabase | Always — needed for all DB operations |
| 2 (Recommended) | context7 | After supabase works — for docs lookup |
| 3 (Optional) | playwright | When you need browser testing |
| 4 (Project-specific) | sqlserver | Only if project needs SQL Server |

### Servers to Skip

| Server | Reason |
|--------|--------|
| sequentialthinking | Useless — Claude Code doesn't need it |
| memory | Redundant — Claude Code has built-in memory |
| puppeteer | Redundant — playwright does the same thing better |
| github | Docker overhead — `gh` CLI works fine instead |

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Claude Code stalls after enabling MCP | Too many servers. Disable all, re-enable one at a time |
| `execute_sql` fails with `$` in query | Dollar-quoting not supported. Use single-quote quoting |
| Server shows "connecting..." forever | Kill Claude Code, restart, check `npx` can run |
| Permission denied on MCP tool | Add to `autoApprove` list in mcp.json OR add to `settings.local.json` allow list |

---

## Security Notes

- **Never commit real access tokens** to git
- Add `.kiro/settings/mcp.json` to `.gitignore` if it contains secrets
- Use the `mcp.json.template` from the Pack & Go kit as a starting point
- The Supabase access token gives full project access — treat it like a password
