# Spec 301: Group Category Management — Design

**Created:** 2026-02-14 18:00 WITA

## Architecture

```
/groups (enhanced)
  ├── Service Layer
  │    ├── groupCategoryService.ts
  │    │    ├── fetchCategories()
  │    │    ├── upsertCategory(category)
  │    │    ├── reorderCategories(ids[])
  │    │    └── deleteCategory(id)
  │    └── groupService.ts (extend existing)
  │         ├── updateGroupCategory(groupId, categoryId)
  │         └── bulkUpdateGroupCategory(groupIds[], categoryId)
  ├── Components
  │    ├── CategoryBadge — small colored pill showing category
  │    ├── CategoryPicker — dropdown to assign category to group(s)
  │    ├── CategoryFilter — filter bar/tabs on Groups page
  │    └── CategoryManager — modal/panel to CRUD categories
  └── Hooks
       └── useGroupCategories() — fetch + cache categories

/briefings (enhanced)
  └── BriefingSummaryRenderer
       └── Group items by category using group name → category lookup
```

## Database Changes

### New Table: `hmso.group_categories`

```sql
CREATE TABLE IF NOT EXISTS hmso.group_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT NOT NULL UNIQUE,
  label TEXT NOT NULL,
  color TEXT NOT NULL DEFAULT 'gray',
  icon TEXT DEFAULT NULL,
  sort_order INTEGER NOT NULL DEFAULT 50,
  briefing_priority INTEGER NOT NULL DEFAULT 5,
  description TEXT DEFAULT NULL,
  name_patterns TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE hmso.group_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view group_categories"
  ON hmso.group_categories FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can manage group_categories"
  ON hmso.group_categories FOR ALL
  USING (auth.uid() IS NOT NULL);

-- Register
INSERT INTO hm_core.object_registry (object_type, object_name, object_schema, owner_app, description)
VALUES ('table', 'group_categories', 'hmso', 'hmso', 'Group category definitions for organizing WhatsApp groups by relevance');
```

Key fields:
- `slug` — machine-readable identifier (e.g., `hm_operations`)
- `label` — display name (e.g., "HM Operations")
- `color` — Tailwind color name (e.g., `emerald`, `blue`, `gray`)
- `sort_order` — display order on Groups page
- `briefing_priority` — 1-3 expanded, 4-6 collapsed, 7-9 hidden in briefings
- `name_patterns` — array of SQL LIKE patterns for auto-classification (e.g., `{"%[HM]%", "%Hokky%"}`)

### Alter Table: `hmso.groups`

```sql
ALTER TABLE hmso.groups
  ADD COLUMN category_id UUID REFERENCES hmso.group_categories(id) ON DELETE SET NULL;

CREATE INDEX idx_groups_category_id ON hmso.groups(category_id);
```

### Seed Data

```sql
INSERT INTO hmso.group_categories (slug, label, color, sort_order, briefing_priority, name_patterns, description) VALUES
  ('hm_operations', 'HM Operations', 'emerald', 10, 1, '{"[HM]%", "Hokky%", "HM %", "HM-%"}', 'HollyMart core operational groups'),
  ('hm_projects', 'HM Projects', 'blue', 20, 2, '{"HM0%", "%Grand Opening%", "%Business Plan%"}', 'HollyMart project-specific groups'),
  ('church_community', 'Church & Ministry', 'purple', 30, 5, '{"GPdI%", "%GPdI%", "%Narwastu%", "%FKGK%", "%STEMI%", "%STTII%", "%Natal%", "%Paskah%"}', 'Church and ministry groups'),
  ('business_network', 'Business Network', 'amber', 40, 4, '{"PSMTI%", "%PSMTI%", "%KADIN%", "%APRINDO%", "%TRIMEGAH%", "%Retail%"}', 'Business associations and networking'),
  ('learning_fomo', 'Learning & Events', 'cyan', 50, 6, '{"Workshop%", "%Workshop%", "%Bootcamp%", "%Seminar%", "%Coaching%", "%Mentoring%", "%Sekolah CEO%", "%Sekolah COO%", "Alumni %Building%", "WFH %Top Coach%", "BB RECRUITMENT%", "BR GREAT%", "Leadership Trans%", "CEO %", "Certified%"}', 'Workshops, seminars, bootcamps — FOMO groups'),
  ('family_personal', 'Family & Personal', 'pink', 60, 7, '{"Keluarga%", "%Family%", "%Familyx%", "Hen Mama%", "%Cousins%", "Gracia%", "Lie Family%", "Bertiga%"}', 'Family and personal groups'),
  ('external_vendor', 'Vendors & Partners', 'orange', 70, 5, '{"Samudra%", "%Simpatindo%", "%Eyos%", "%BNI%", "%BRI%", "%Linkaja%", "%Talenta%", "%Zahir%", "%Koffieshop%", "%Koffiesoft%"}', 'Vendor and supplier groups'),
  ('alumni_social', 'Alumni & Social', 'slate', 80, 8, '{"Alumni%", "%MAPRADA%", "%Arek%", "%Infor Petra%", "%Petra%", "%Marga%", "%BHINNEKA%", "%Boatang%", "%Mbojo%"}', 'Alumni reunions and social groups'),
  ('uncategorized', 'Uncategorized', 'gray', 99, 9, '{}', 'Groups not yet categorized');
```

### Auto-Classification Migration

```sql
-- Auto-classify existing groups based on name patterns
-- For each category, update groups whose name matches any pattern
DO $$
DECLARE
  cat RECORD;
  pattern TEXT;
BEGIN
  FOR cat IN SELECT id, name_patterns FROM hmso.group_categories WHERE array_length(name_patterns, 1) > 0
  LOOP
    FOREACH pattern IN ARRAY cat.name_patterns
    LOOP
      UPDATE hmso.groups
      SET category_id = cat.id
      WHERE category_id IS NULL
        AND name LIKE pattern;
    END LOOP;
  END LOOP;
END $$;

-- Set remaining uncategorized
UPDATE hmso.groups
SET category_id = (SELECT id FROM hmso.group_categories WHERE slug = 'uncategorized')
WHERE category_id IS NULL;
```

### Rollback Plan

```sql
ALTER TABLE hmso.groups DROP COLUMN IF EXISTS category_id;
DROP TABLE IF EXISTS hmso.group_categories;
DELETE FROM hm_core.object_registry WHERE object_name = 'group_categories' AND owner_app = 'hmso';
```

## Service Layer Design

### `src/services/group-category-service.ts` (new)
- `fetchCategories()` → returns all categories ordered by `sort_order`
- `upsertCategory(data)` → create or update a category
- `reorderCategories(orderedIds)` → batch update `sort_order`
- `deleteCategory(id)` → delete (groups fall back to uncategorized)
- `updateGroupCategory(groupId, categoryId)` → single group assignment
- `bulkUpdateGroupCategory(groupIds, categoryId)` → batch assignment

## Component Design

### CategoryBadge
Small colored pill: `<span class="px-2 py-0.5 text-xs rounded-full bg-{color}-50 text-{color}-700">HM Operations</span>`

### CategoryPicker
Dropdown select with color dots. Used in:
- Group card (click to change)
- Group detail header
- Bulk action bar

### CategoryFilter
Horizontal scrollable pill bar on Groups page. "All" + each category with count. Clicking filters the list.

### CategoryManager
Modal or slide-over panel accessible from Groups page header. CRUD for categories:
- Reorder via drag or up/down buttons
- Edit label, color, briefing_priority
- Edit name_patterns (for auto-classification of future groups)
- "Re-run auto-classify" button to re-apply patterns to uncategorized groups

### BriefingSummaryRenderer Enhancement
- When rendering task/direction items, look up the group name in the item's `[Group Name]` tag
- Match against a categories-by-group-name map (fetched once)
- Group items by category, ordered by `briefing_priority`
- Each category section uses the category's color and label

## Key Decisions

1. **Categories in DB, not hardcoded** — Hendra can add/rename/reorder without code changes. Name patterns stored in the category row enable auto-classification.
2. **`briefing_priority` as integer** — Simple numeric priority. 1-3 = expanded, 4-6 = collapsed, 7-9 = hidden. Easy to adjust per category.
3. **Name patterns as TEXT[]** — SQL LIKE patterns stored in the category. Simple, no regex complexity. Can be edited from UI.
4. **Single category per group** — No multi-tagging. Keeps it simple. A group is either HM Operations or it's not.
5. **Seed + auto-classify in one migration** — Creates categories and classifies all 299 existing groups in one shot. Hendra can adjust after.

## UI Specifications

### Groups Page Changes
- Category filter bar below search (horizontal scroll on mobile)
- Category badge on each group card (top-right area, next to star)
- "Manage Categories" button in page header (gear icon)
- Bulk select mode: checkbox on each card → floating action bar with category picker

### Briefing Page Changes
- Items grouped under category headers with color coding
- Category sections ordered by `briefing_priority`
- Sections with priority 7-9 collapsed into a "Other Groups" accordion

### Mobile Behavior
- Category filter scrolls horizontally
- Category picker is a bottom sheet
- Bulk select uses long-press to enter selection mode
