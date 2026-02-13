# MCP Server Setup Guide

> **Updated:** 2026-02-13 WITA
>
> How to configure Model Context Protocol (MCP) servers for AI coding assistants.

---

## Configuration Location

**Kiro:** `.kiro/settings/mcp.json`
**Claude Code:** `.claude/settings.local.json` (enabledMcpjsonServers)

**NEVER duplicate servers in both places** — causes stalling.

---

## Available Servers

### 1. Supabase MCP (Essential)
Provides: `execute_sql`, `apply_migration`, `list_tables`, `list_migrations`, `search_docs`

### 2. Context7 (Documentation lookup)
Provides: `resolve-library-id`, `get-library-docs`

### 3. Playwright (Browser testing)
Provides: `browser_navigate`, `browser_click`, `browser_snapshot`, etc.

### 4. SQL Server (HollyMart POS data)
Provides: `sql_query`, `list_databases`, `list_tables`, `describe_table`

---

## Setup Process

Enable one at a time. Priority: supabase → context7 → playwright → sqlserver.

---

## Security Notes

- Never commit real access tokens to git
- Add MCP config files to `.gitignore` if they contain secrets
- Supabase access token gives full project access — treat it like a password
