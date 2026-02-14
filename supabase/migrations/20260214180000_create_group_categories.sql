-- Migration: Create group_categories table and seed data
-- Spec: 301-group-category-management
-- Task: 1.1
-- Created: 2026-02-14 18:00 WITA

-- Create group_categories table
CREATE TABLE IF NOT EXISTS wa_intel.group_categories (
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

-- Enable RLS
ALTER TABLE wa_intel.group_categories ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Authenticated users can view group_categories"
  ON wa_intel.group_categories FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can manage group_categories"
  ON wa_intel.group_categories FOR ALL
  USING (auth.uid() IS NOT NULL);

-- Seed default categories
INSERT INTO wa_intel.group_categories (slug, label, color, sort_order, briefing_priority, name_patterns, description) VALUES
  ('hm_operations', 'HM Operations', 'emerald', 10, 1, '{"[HM]%", "Hokky%", "HM %", "HM-%"}', 'HollyMart core operational groups'),
  ('hm_projects', 'HM Projects', 'blue', 20, 2, '{"HM0%", "%Grand Opening%", "%Business Plan%"}', 'HollyMart project-specific groups'),
  ('church_community', 'Church & Ministry', 'purple', 30, 5, '{"GPdI%", "%GPdI%", "%Narwastu%", "%FKGK%", "%STEMI%", "%STTII%", "%Natal%", "%Paskah%"}', 'Church and ministry groups'),
  ('business_network', 'Business Network', 'amber', 40, 4, '{"PSMTI%", "%PSMTI%", "%KADIN%", "%APRINDO%", "%TRIMEGAH%", "%Retail%"}', 'Business associations and networking'),
  ('learning_fomo', 'Learning & Events', 'cyan', 50, 6, '{"Workshop%", "%Workshop%", "%Bootcamp%", "%Seminar%", "%Coaching%", "%Mentoring%", "%Sekolah CEO%", "%Sekolah COO%", "Alumni %Building%", "WFH %Top Coach%", "BB RECRUITMENT%", "BR GREAT%", "Leadership Trans%", "CEO %", "Certified%"}', 'Workshops, seminars, bootcamps — FOMO groups'),
  ('family_personal', 'Family & Personal', 'pink', 60, 7, '{"Keluarga%", "%Family%", "%Familyx%", "Hen Mama%", "%Cousins%", "Gracia%", "Lie Family%", "Bertiga%"}', 'Family and personal groups'),
  ('external_vendor', 'Vendors & Partners', 'orange', 70, 5, '{"Samudra%", "%Simpatindo%", "%Eyos%", "%BNI%", "%BRI%", "%Linkaja%", "%Talenta%", "%Zahir%", "%Koffieshop%", "%Koffiesoft%"}', 'Vendor and supplier groups'),
  ('alumni_social', 'Alumni & Social', 'slate', 80, 8, '{"Alumni%", "%MAPRADA%", "%Arek%", "%Infor Petra%", "%Petra%", "%Marga%", "%BHINNEKA%", "%Boatang%", "%Mbojo%"}', 'Alumni reunions and social groups'),
  ('uncategorized', 'Uncategorized', 'gray', 99, 9, '{}', 'Groups not yet categorized');

-- Register in object registry
INSERT INTO hm_core.object_registry (object_type, object_name, object_schema, owner_app, description)
VALUES ('table', 'group_categories', 'wa_intel', 'wa_intel', 'Group category definitions for organizing WhatsApp groups by relevance');
