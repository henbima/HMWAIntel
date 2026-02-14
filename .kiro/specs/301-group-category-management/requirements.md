# Spec 301: Group Category Management — Requirements

**Status:** Planned
**Phase:** 1
**Complexity:** Medium
**Assignable to:** Sonnet / Opus
**Depends on:** None
**Page:** `/groups` (enhanced), `/briefings` (enhanced renderer)
**Created:** 2026-02-14 18:00 WITA

## Overview

Add a category system to WhatsApp groups so that briefings, dashboards, and group listings can prioritize what matters. Currently all 299 groups are treated equally — HollyMart operational groups sit next to nostalgic alumni groups and FOMO seminar groups. This makes the daily briefing cluttered and hard to scan. The Elon principle: ruthlessly categorize, then filter by what drives decisions.

## Problem Statement

1. The Daily Briefings page dumps all group activity into a single flat list with no grouping or priority
2. The Groups page only distinguishes "starred" vs "not starred" — no semantic categorization
3. Hendra wastes time scanning through church groups, seminar spam, and alumni chats to find HollyMart operational items
4. New groups get added constantly (299 and growing) with no automatic categorization
5. Categories should be user-adjustable, not hardcoded — Hendra's context about each group is the source of truth

## User Stories

- As Hendra, I want groups categorized by relevance so that my daily briefing shows HM operations first and hides seminar noise
- As Hendra, I want to quickly recategorize groups from the Groups page so that the system stays accurate as groups evolve
- As Hendra, I want the briefing to group items by category so that I can scan what matters in 5 seconds
- As Hendra, I want new groups to be auto-suggested a category based on name patterns so that I don't have to manually tag every new group

## Key Requirements

### Category System
- Categories stored in a `group_categories` table (not hardcoded) so Hendra can add/rename/reorder
- Default seed categories:
  - `hm_operations` — HollyMart operational groups ([HM] prefix, Hokky prefix)
  - `hm_projects` — HollyMart project-specific groups (temporary, event-based)
  - `church_community` — Church and ministry groups (GPdI, Narwastu, FKGK, etc.)
  - `business_network` — Business networking, associations (PSMTI, KADIN, APRINDO, etc.)
  - `learning_fomo` — Workshops, seminars, bootcamps, coaching groups
  - `family_personal` — Family and personal groups
  - `external_vendor` — Vendor/supplier groups
  - `alumni_social` — Alumni and social groups
  - `uncategorized` — Default for new/unclassified groups
- Each category has: `slug`, `label`, `color`, `icon`, `sort_order`, `briefing_priority` (1=show first, 9=collapse/hide)
- `briefing_priority` controls how the category appears in briefings:
  - 1-3: Expanded by default in briefing
  - 4-6: Collapsed but visible
  - 7-9: Hidden unless explicitly expanded

### Group-Category Assignment
- Add `category_id` FK to `hmso.groups` table
- One-time seed migration to auto-classify existing 299 groups based on name patterns
- Bulk category editor on Groups page (select multiple → assign category)
- Individual category picker on group card/detail

### Briefing Enhancement
- BriefingSummaryRenderer groups items by category, ordered by `briefing_priority`
- Each category section shows its label, color, and item count
- High-priority categories expanded, low-priority collapsed

### Groups Page Enhancement
- Filter by category (dropdown or tab bar)
- Category badge on each group card
- Category management section (add/edit/reorder categories)

## Data Source

- `hmso.groups` (existing, add `category_id` FK)
- `hmso.group_categories` (new table)

## Acceptance Criteria

- [ ] `group_categories` table created with seed data (9 default categories)
- [ ] `groups.category_id` column added with FK to `group_categories`
- [ ] Existing 299 groups auto-classified by name pattern migration
- [ ] Groups page shows category badge on each card
- [ ] Groups page has category filter (dropdown or tabs)
- [ ] Groups page has bulk category assignment (select → assign)
- [ ] Individual group detail shows category picker
- [ ] BriefingSummaryRenderer groups items by category with priority ordering
- [ ] Category management UI (add/edit/reorder/set briefing priority)
- [ ] New objects registered in `hm_core.object_registry`
- [ ] Dashboard loads efficiently
- [ ] Mobile layout is usable

## Out of Scope

- AI-powered auto-categorization of new groups (future spec — can use GPT to suggest)
- Per-group notification settings
- Group archiving/deletion
- Changes to the WhatsApp listener
