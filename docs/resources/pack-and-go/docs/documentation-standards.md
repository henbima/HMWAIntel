# Documentation Standards

> **Updated:** 2026-02-11 22:00 WITA
>
> How to organize and maintain project documentation.

---

## Folder Structure

```
docs/
├── Hendra_Core_Package/       # Universal HollyMart identity docs (DO NOT MODIFY)
│   ├── company_brief.md
│   ├── Hendra Operating System v1 (HOS v1).md
│   ├── HENDRA AI GOVERNANCE PROMPT PACK v1.md
│   ├── hollymart_org_structure.md
│   └── ...
├── project-context.md          # Project background, tech stack, safety rules
├── roadmap.md                  # Phased implementation roadmap
└── {topic-specific docs}       # As needed (server-infrastructure.md, etc.)
```

---

## Document Types

### 1. Project Context (`project-context.md`)
- What the project is and why it exists
- Tech stack and architecture
- Safety rules and constraints
- Related systems
- Key people

### 2. Roadmap (`roadmap.md`)
- Phased implementation plan
- Spec assignments and dependencies
- Decision log
- Success metrics

### 3. Discovery Docs (`discovery/`)
- Output from database/system exploration
- Schema documentation
- Data flow diagrams
- Feasibility studies

### 4. Spec Docs (`specs/`)
- requirements.md — What to build
- design.md — How to build it
- tasks.md — Implementation checklist

---

## Writing Standards

### Timestamps
- **Always include date AND time** (WITA, HH:MM format) on all file changes
- Rapid development means hours matter for tracking progress
- Format: `2026-02-11 22:00 WITA`

### Headers
- Every document starts with a title (`# Title`)
- Include a metadata block: version, date, author
- Use blockquote for document description

### Markdown Conventions
- Use tables for structured data
- Use code blocks for SQL, TypeScript, shell commands
- Use checkboxes for checklists
- Use blockquotes for important notes

### Content Rules
- Be specific and actionable — avoid vague descriptions
- Include examples where possible
- Cross-reference related documents
- Keep documents focused — one topic per file
- Update existing docs rather than creating new ones

---

## Maintenance Rules

1. **SPEC_REGISTRY.md** is the single source of truth for spec status — always update it
2. **TECHNICAL_DEBT_REGISTRY.md** tracks known issues — add items as you discover them
3. **CLAUDE.md** is the AI's primary instruction file — keep it current
4. **Discovery docs** are append-only — don't delete findings, add new ones
5. **Completed specs** move to `specs/_completed/` — never delete spec folders

---

## What NOT to Document

- Session-specific context (current task details, temporary state)
- Information that duplicates CLAUDE.md
- Speculative conclusions from reading a single file
- Internal implementation details that are obvious from the code
