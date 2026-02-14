-- Migration: Add category_id to groups table and auto-classify
-- Spec: 301-group-category-management
-- Task: 1.2
-- Created: 2026-02-14 18:01 WITA

-- Add category_id column to wa_intel.groups
ALTER TABLE wa_intel.groups
  ADD COLUMN category_id UUID REFERENCES wa_intel.group_categories(id) ON DELETE SET NULL;

-- Create index for performance
CREATE INDEX idx_groups_category_id ON wa_intel.groups(category_id);

-- Auto-classify existing groups based on name patterns
-- For each category, update groups whose name matches any pattern
DO $$
DECLARE
  cat RECORD;
  pattern TEXT;
BEGIN
  FOR cat IN SELECT id, name_patterns FROM wa_intel.group_categories WHERE array_length(name_patterns, 1) > 0
  LOOP
    FOREACH pattern IN ARRAY cat.name_patterns
    LOOP
      UPDATE wa_intel.groups
      SET category_id = cat.id
      WHERE category_id IS NULL
        AND name ILIKE pattern;
    END LOOP;
  END LOOP;
END $$;

-- Set remaining uncategorized groups
UPDATE wa_intel.groups
SET category_id = (SELECT id FROM wa_intel.group_categories WHERE slug = 'uncategorized')
WHERE category_id IS NULL;
