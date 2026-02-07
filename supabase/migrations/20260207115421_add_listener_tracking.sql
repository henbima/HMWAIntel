/*
  # Add Multi-Listener Support
  
  ## Overview
  Enables tracking which WhatsApp listener instance captured each message, group, and contact.
  This supports running multiple listeners simultaneously for redundancy and failover.
  
  ## Changes Made
  
  ### 1. Messages Table
  - Added `listener_id` column (text, nullable) to track which listener captured each message
  - Added `last_seen_by_listener` column (timestamptz) to track when the message was last seen
  
  ### 2. Groups Table
  - Added `listener_id` column to track which listener last synced the group
  - Added `last_synced_at` column to track when the group was last synced by any listener
  
  ### 3. Contacts Table
  - Added `listener_id` column to track which listener last resolved/updated the contact
  - Added `last_resolved_at` column to track when the contact was last resolved
  
  ### 4. Group Members Table
  - Added `listener_id` column to track which listener captured the membership
  
  ## Use Cases
  - **Redundancy**: Run personal + company numbers simultaneously
  - **Failover**: Automatic takeover if primary listener is banned
  - **Monitoring**: Track which listener is active and capturing data
  - **Debugging**: Identify if a specific listener is having issues
  
  ## Notes
  - `listener_id` is nullable to support existing data
  - On conflict, newer data from any listener takes precedence
  - Recommended listener_id format: "personal" or "company" (simple, readable)
*/

-- Add listener tracking to messages table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'wa_intel' AND table_name = 'messages' AND column_name = 'listener_id'
  ) THEN
    ALTER TABLE wa_intel.messages ADD COLUMN listener_id text;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'wa_intel' AND table_name = 'messages' AND column_name = 'last_seen_by_listener'
  ) THEN
    ALTER TABLE wa_intel.messages ADD COLUMN last_seen_by_listener timestamptz DEFAULT now();
  END IF;
END $$;

-- Add listener tracking to groups table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'wa_intel' AND table_name = 'groups' AND column_name = 'listener_id'
  ) THEN
    ALTER TABLE wa_intel.groups ADD COLUMN listener_id text;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'wa_intel' AND table_name = 'groups' AND column_name = 'last_synced_at'
  ) THEN
    ALTER TABLE wa_intel.groups ADD COLUMN last_synced_at timestamptz;
  END IF;
END $$;

-- Add listener tracking to contacts table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'wa_intel' AND table_name = 'contacts' AND column_name = 'listener_id'
  ) THEN
    ALTER TABLE wa_intel.contacts ADD COLUMN listener_id text;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'wa_intel' AND table_name = 'contacts' AND column_name = 'last_resolved_at'
  ) THEN
    ALTER TABLE wa_intel.contacts ADD COLUMN last_resolved_at timestamptz;
  END IF;
END $$;

-- Add listener tracking to group_members table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'wa_intel' AND table_name = 'group_members' AND column_name = 'listener_id'
  ) THEN
    ALTER TABLE wa_intel.group_members ADD COLUMN listener_id text;
  END IF;
END $$;

-- Create index for efficient listener queries
CREATE INDEX IF NOT EXISTS idx_messages_listener_id ON wa_intel.messages(listener_id);
CREATE INDEX IF NOT EXISTS idx_groups_listener_id ON wa_intel.groups(listener_id);
CREATE INDEX IF NOT EXISTS idx_contacts_listener_id ON wa_intel.contacts(listener_id);