/*
  # Add Starred Groups Feature

  1. Changes
    - Add `is_starred` column to `groups` table for favoriting groups
    - Default value is false
    - Users can star groups to monitor them on the dashboard

  2. Security
    - Existing RLS policies already protect the groups table
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'wa_intel' AND table_name = 'groups' AND column_name = 'is_starred'
  ) THEN
    ALTER TABLE wa_intel.groups ADD COLUMN is_starred boolean DEFAULT false;
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_groups_is_starred ON wa_intel.groups(is_starred) WHERE is_starred = true;