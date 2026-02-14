-- Fix missing GRANT permissions on wa_intel.group_categories
-- The table had RLS policies but no base role grants, causing 403 errors

GRANT SELECT ON wa_intel.group_categories TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON wa_intel.group_categories TO authenticated;
