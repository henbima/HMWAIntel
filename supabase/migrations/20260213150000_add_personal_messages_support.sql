-- Migration: Add personal messages support to wa_intel.messages
-- Purpose: Extend messages table to support personal/direct WhatsApp messages
--          alongside existing group messages. Adds conversation_type discriminator,
--          contact JID column, relaxes wa_group_id NOT NULL, and updates today_summary view.
-- Spec: personal-messages-capture

-- 1. Add conversation_type column (defaults to 'group' for all existing rows)
ALTER TABLE wa_intel.messages
  ADD COLUMN IF NOT EXISTS conversation_type TEXT NOT NULL DEFAULT 'group';

-- 2. Add wa_contact_jid column for personal message contact tracking
ALTER TABLE wa_intel.messages
  ADD COLUMN IF NOT EXISTS wa_contact_jid TEXT;

-- 3. Relax wa_group_id NOT NULL constraint (personal messages have NULL wa_group_id)
ALTER TABLE wa_intel.messages
  ALTER COLUMN wa_group_id DROP NOT NULL;

-- 4. Create indexes for personal message queries
CREATE INDEX IF NOT EXISTS idx_messages_conversation_type
  ON wa_intel.messages (conversation_type);

CREATE INDEX IF NOT EXISTS idx_messages_contact_jid
  ON wa_intel.messages (wa_contact_jid)
  WHERE wa_contact_jid IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_messages_personal_contact_time
  ON wa_intel.messages (wa_contact_jid, "timestamp" DESC)
  WHERE conversation_type = 'personal';

-- 5. Update today_summary view to explicitly exclude personal messages
CREATE OR REPLACE VIEW wa_intel.today_summary AS
SELECT g.name AS group_name,
    g.wa_group_id,
    count(m.id) AS total_messages,
    count(ci.id) FILTER (WHERE ci.classification = 'task') AS task_count,
    count(ci.id) FILTER (WHERE ci.classification = 'direction') AS direction_count,
    count(ci.id) FILTER (WHERE ci.classification = 'report') AS report_count
FROM wa_intel.groups g
    LEFT JOIN wa_intel.messages m
      ON m.wa_group_id = g.wa_group_id
      AND m."timestamp" >= CURRENT_DATE
      AND m.conversation_type = 'group'
    LEFT JOIN wa_intel.classified_items ci ON ci.message_id = m.id
GROUP BY g.name, g.wa_group_id;

-- 6. Register view in hm_core.object_registry
-- Note: registry only supports types: table, function, cron_job, edge_function, schema, view, trigger
-- Columns and indexes are tracked as part of their parent table (messages, already registered)
INSERT INTO hm_core.object_registry (object_type, object_name, object_schema, owner_app, description)
VALUES
  ('view', 'today_summary', 'wa_intel', 'wa_intel', 'Daily summary view - updated to exclude personal messages')
ON CONFLICT DO NOTHING;

-- 7. Refresh PostgREST schema cache
NOTIFY pgrst, 'reload schema';
