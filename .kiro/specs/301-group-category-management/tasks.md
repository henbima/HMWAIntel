# Spec 301: Group Category Management — Tasks

**Status:** Complete
**Created:** 2026-02-14 18:00 WITA
**Total Tasks:** 10

## Tasks

### Phase 1: Database & Service Layer

#### - [x] Task 1.1: Create group_categories table and seed data
**Delegate to:** Sonnet
**File:** `HMSO/supabase/migrations/20260214180000_create_group_categories.sql`

**Implementation notes:**
- Create `hmso.group_categories` table with all columns from design
- Enable RLS with authenticated user policies
- Seed 9 default categories with name_patterns
- Register in `hm_core.object_registry`
- Apply via `mcp_supabase_apply_migration`
- Save local copy for git tracking

**Acceptance Criteria:**
- [x] Table created with correct schema
- [x] RLS enabled with SELECT and ALL policies
- [x] 9 seed categories inserted
- [x] Object registered in `hm_core.object_registry`

**Commit:** `feat(301): create group_categories table with seed data`

---

#### - [x] Task 1.2: Add category_id to groups table and auto-classify
**Delegate to:** Sonnet
**File:** `HMSO/supabase/migrations/20260214180100_add_group_category_id.sql`

**Implementation notes:**
- ALTER `hmso.groups` to add `category_id` UUID FK
- Create index on `category_id`
- Run auto-classification loop matching name patterns
- Set remaining groups to `uncategorized`
- Apply via `mcp_supabase_apply_migration`

**Acceptance Criteria:**
- [x] `category_id` column added to `hmso.groups`
- [x] Index created
- [x] All 299 existing groups have a category assigned
- [x] Verify classification accuracy with spot checks

**Commit:** `feat(301): add category_id to groups and auto-classify`

---

#### - [x] Task 1.3: Create group category service
**Delegate to:** Sonnet
**File:** `HMSO/src/services/group-category-service.ts`
**Pattern:** Follow `HMSO/src/lib/supabase.ts` for waIntel usage

**Imports:**
- `import { waIntel } from '../lib/supabase'`

**Types to define:**
- `GroupCategory` — id (UUID), slug (string), label (string), color (string), icon (string|null), sort_order (number), briefing_priority (number), description (string|null), name_patterns (string[]), created_at (string), updated_at (string)
- Define in `HMSO/src/services/group-category-service.ts` (co-located)

**Implementation notes:**
- `fetchCategories()` → SELECT * ordered by sort_order
- `upsertCategory(data)` → upsert by id
- `reorderCategories(orderedIds)` → batch update sort_order
- `deleteCategory(id)` → delete, reassign groups to uncategorized
- `updateGroupCategory(groupId, categoryId)` → update single group
- `bulkUpdateGroupCategory(groupIds, categoryId)` → batch update groups

**Acceptance Criteria:**
- [x] All 6 service functions implemented
- [x] Proper error handling
- [x] TypeScript types defined

**Commit:** `feat(301): create group category service layer`

---

#### - [x] Task 1.4: Create useGroupCategories hook
**Delegate to:** Haiku
**File:** `HMSO/src/hooks/useGroupCategories.ts`
**Pattern:** Follow existing hooks in `HMSO/src/hooks/`

**Imports:**
- `import { useState, useEffect } from 'react'`
- `import { fetchCategories, type GroupCategory } from '../services/group-category-service'`

**Implementation notes:**
- Fetch categories on mount
- Cache in state
- Expose `categories`, `loading`, `refetch`
- Build `categoryMap` (id → category) and `categoryBySlug` (slug → category) for quick lookups

**Acceptance Criteria:**
- [x] Hook returns categories, loading, refetch, categoryMap, categoryBySlug
- [x] Categories fetched on mount

**Commit:** `feat(301): create useGroupCategories hook`

---

### Phase 2: UI Components

#### - [x] Task 2.1: Create CategoryBadge component
**Delegate to:** Haiku
**File:** `HMSO/src/components/CategoryBadge.tsx`
**Pattern:** Follow `HMSO/src/components/StatusBadge.tsx`

**Implementation notes:**
- Small colored pill showing category label
- Props: `category: GroupCategory | null`, `size?: 'sm' | 'md'`
- Color mapped from category.color to Tailwind classes
- Show "Uncategorized" in gray if null

**Acceptance Criteria:**
- [x] Renders colored pill with category label
- [x] Handles null category gracefully
- [x] Supports sm and md sizes

**Commit:** `feat(301): create CategoryBadge component`

---

#### - [x] Task 2.2: Create CategoryPicker component
**Delegate to:** Sonnet
**File:** `HMSO/src/components/CategoryPicker.tsx`

**Imports:**
- `import { useGroupCategories } from '../hooks/useGroupCategories'`
- `import { type GroupCategory } from '../services/group-category-service'`

**Implementation notes:**
- Dropdown select with color dots next to each option
- Props: `value: string | null`, `onChange: (categoryId: string) => void`, `size?: 'sm' | 'md'`
- Uses useGroupCategories hook for options
- Compact design for use in cards and detail views

**Acceptance Criteria:**
- [x] Dropdown shows all categories with color indicators
- [x] Calls onChange with selected category id
- [x] Works in both card and detail contexts

**Commit:** `feat(301): create CategoryPicker component`

---

#### - [x] Task 2.3: Create CategoryFilter component
**Delegate to:** Sonnet
**File:** `HMSO/src/components/CategoryFilter.tsx`

**Implementation notes:**
- Horizontal scrollable pill bar
- "All" pill + one pill per category with group count
- Props: `selectedCategory: string | null`, `onChange: (slug: string | null) => void`, `groupCounts: Record<string, number>`
- Active pill uses category color, inactive is gray

**Acceptance Criteria:**
- [x] Shows "All" + category pills with counts
- [x] Horizontal scroll on mobile
- [x] Active state uses category color

**Commit:** `feat(301): create CategoryFilter component`

---

### Phase 3: Page Integration

#### - [x] Task 3.1: Enhance GroupsPage with category system
**Delegate to:** Opus
**File:** `HMSO/src/pages/GroupsPage.tsx`

**Implementation notes:**
- Add CategoryFilter below search bar
- Add CategoryBadge to GroupCard (near star icon)
- Add CategoryPicker to GroupDetail header
- Add category filter to filteredAndSortedGroups logic
- Group the grid by category when no search active (optional, discuss with Hendra)
- Add "Manage Categories" gear button in header → opens CategoryManager modal

**Acceptance Criteria:**
- [x] Category filter bar visible and functional
- [x] Group cards show category badge
- [x] Group detail shows category picker
- [x] Filtering by category works correctly
- [x] Manage Categories button opens manager

**Commit:** `feat(301): integrate category system into GroupsPage`

---

#### - [x] Task 3.2: Create CategoryManager modal
**Delegate to:** Opus
**File:** `HMSO/src/components/CategoryManager.tsx`

**Implementation notes:**
- Modal/slide-over panel for CRUD on categories
- List all categories with: label, color swatch, briefing_priority, group count
- Edit: label, color (preset picker), briefing_priority (1-9 slider or dropdown), name_patterns (textarea, one per line)
- Add new category
- Reorder via up/down buttons
- "Re-run auto-classify" button: applies name_patterns to uncategorized groups
- Delete category (with confirmation, reassigns groups to uncategorized)

**Acceptance Criteria:**
- [x] Can view all categories with their settings
- [x] Can edit label, color, briefing_priority, name_patterns
- [x] Can add new category
- [x] Can reorder categories
- [x] Can delete category (groups reassigned)
- [x] Re-run auto-classify works

**Commit:** `feat(301): create CategoryManager modal`

---

#### - [x] Task 3.3: Enhance BriefingSummaryRenderer with category grouping
**Delegate to:** Opus
**File:** `HMSO/src/components/BriefingSummaryRenderer.tsx`

**Implementation notes:**
- Fetch categories and groups-to-category mapping on mount
- When rendering task/direction sections, sub-group items by category
- Order category sub-groups by `briefing_priority`
- Categories with priority 1-3: expanded by default
- Categories with priority 4-6: collapsed but visible
- Categories with priority 7-9: hidden under "Lainnya" accordion
- Each category sub-group shows colored header with label and item count
- Falls back to current behavior if categories not loaded

**Acceptance Criteria:**
- [x] Briefing items grouped by category within each section
- [x] Category ordering follows briefing_priority
- [x] High-priority categories expanded, low-priority collapsed/hidden
- [x] Graceful fallback if categories unavailable
- [x] Visual distinction between category groups

**Commit:** `feat(301): enhance briefing renderer with category grouping`

---

## Post-Implementation Checklist
- [x] All tasks marked complete
- [ ] `npm run typecheck` passes
- [x] `npm run build` passes
- [ ] Verify auto-classification accuracy (spot check 20+ groups)
- [ ] Test category CRUD from UI
- [ ] Test briefing rendering with categories
- [ ] Implementation report created in `reports/`
- [ ] SPEC_REGISTRY.md updated
