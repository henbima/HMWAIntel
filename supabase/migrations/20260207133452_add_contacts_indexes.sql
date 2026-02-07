/*
  # Add indexes for contacts table

  1. New Indexes
    - `idx_contacts_active_name` - Composite index on is_active and display_name for fast filtered sorting
    - `idx_contacts_location` - Index on location for filter queries
    - `idx_contacts_department` - Index on department for filter queries

  2. Purpose
    - Speed up contacts page queries which filter by is_active and sort by display_name
    - Improve filter performance for location and department dropdowns
*/

CREATE INDEX IF NOT EXISTS idx_contacts_active_name 
ON wa_intel.contacts (is_active, display_name);

CREATE INDEX IF NOT EXISTS idx_contacts_location 
ON wa_intel.contacts (location) 
WHERE location IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_contacts_department 
ON wa_intel.contacts (department) 
WHERE department IS NOT NULL;
