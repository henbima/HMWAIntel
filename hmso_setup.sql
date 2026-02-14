/*
  # HMSO Schema Setup
  Run this SQL in your Supabase SQL Editor:
  https://supabase.com/dashboard/project/nnzhdjibilebpjgaqkdu/sql

  Creates the hmso schema with all tables for the HollyMart Signal Operations system.
  Does NOT touch the public schema or any existing HMCS tables.

  1. Schema - Creates `hmso` schema
  2. Tables: groups, contacts, group_members, messages, classified_items, tasks, directions, daily_briefings
  3. Views: overdue_tasks, today_summary
  4. Security: RLS enabled on all tables
  5. PostgREST: Exposes hmso schema to the API
*/

-- Step 1: Create schema
CREATE SCHEMA IF NOT EXISTS hmso;

-- Step 2: Expose hmso to PostgREST API
ALTER ROLE authenticator SET pgrst.db_schemas TO 'public, graphql_public, hmso';
NOTIFY pgrst, 'reload config';

-- Step 3: Grant schema usage
GRANT USAGE ON SCHEMA hmso TO authenticated;
GRANT USAGE ON SCHEMA hmso TO anon;
GRANT USAGE ON SCHEMA hmso TO service_role;

-- ============================================================
-- TABLE 1: groups
-- ============================================================
CREATE TABLE IF NOT EXISTS hmso.groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wa_group_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    participant_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE hmso.groups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view groups"
  ON hmso.groups FOR SELECT
  TO authenticated
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can insert groups"
  ON hmso.groups FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update groups"
  ON hmso.groups FOR UPDATE
  TO authenticated
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

-- ============================================================
-- TABLE 2: contacts
-- ============================================================
CREATE TABLE IF NOT EXISTS hmso.contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wa_jid TEXT UNIQUE NOT NULL,
    phone_number TEXT,
    display_name TEXT NOT NULL,
    short_name TEXT,
    role TEXT,
    location TEXT,
    department TEXT,
    is_leadership BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    hmcs_employee_id TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE hmso.contacts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view contacts"
  ON hmso.contacts FOR SELECT
  TO authenticated
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can insert contacts"
  ON hmso.contacts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update contacts"
  ON hmso.contacts FOR UPDATE
  TO authenticated
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE INDEX IF NOT EXISTS idx_contacts_jid ON hmso.contacts(wa_jid);
CREATE INDEX IF NOT EXISTS idx_contacts_location ON hmso.contacts(location);

-- ============================================================
-- TABLE 3: group_members
-- ============================================================
CREATE TABLE IF NOT EXISTS hmso.group_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES hmso.groups(id) ON DELETE CASCADE,
    contact_id UUID REFERENCES hmso.contacts(id) ON DELETE CASCADE,
    wa_role TEXT DEFAULT 'member',
    joined_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(group_id, contact_id)
);

ALTER TABLE hmso.group_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view group_members"
  ON hmso.group_members FOR SELECT
  TO authenticated
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can insert group_members"
  ON hmso.group_members FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update group_members"
  ON hmso.group_members FOR UPDATE
  TO authenticated
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

-- ============================================================
-- TABLE 4: messages
-- ============================================================
CREATE TABLE IF NOT EXISTS hmso.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wa_message_id TEXT UNIQUE,
    group_id UUID REFERENCES hmso.groups(id),
    wa_group_id TEXT NOT NULL,
    sender_jid TEXT NOT NULL,
    sender_name TEXT,
    contact_id UUID REFERENCES hmso.contacts(id),
    message_text TEXT,
    message_type TEXT DEFAULT 'text',
    media_url TEXT,
    is_from_hendra BOOLEAN DEFAULT false,
    quoted_message_id TEXT,
    timestamp TIMESTAMPTZ NOT NULL,
    raw_data JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE hmso.messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view messages"
  ON hmso.messages FOR SELECT
  TO authenticated
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can insert messages"
  ON hmso.messages FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE INDEX IF NOT EXISTS idx_messages_group_time ON hmso.messages(wa_group_id, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON hmso.messages(sender_jid);
CREATE INDEX IF NOT EXISTS idx_messages_from_hendra ON hmso.messages(is_from_hendra) WHERE is_from_hendra = true;
CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON hmso.messages(timestamp DESC);

-- ============================================================
-- TABLE 5: classified_items
-- ============================================================
CREATE TABLE IF NOT EXISTS hmso.classified_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID REFERENCES hmso.messages(id) ON DELETE CASCADE,
    classification TEXT NOT NULL,
    confidence REAL,
    summary TEXT,
    assigned_to TEXT,
    assigned_by TEXT,
    deadline TEXT,
    deadline_parsed TIMESTAMPTZ,
    topic TEXT,
    priority TEXT DEFAULT 'normal',
    ai_model TEXT,
    classified_at TIMESTAMPTZ DEFAULT now(),
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE hmso.classified_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view classified_items"
  ON hmso.classified_items FOR SELECT
  TO authenticated
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can insert classified_items"
  ON hmso.classified_items FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update classified_items"
  ON hmso.classified_items FOR UPDATE
  TO authenticated
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE INDEX IF NOT EXISTS idx_classified_type ON hmso.classified_items(classification);
CREATE INDEX IF NOT EXISTS idx_classified_time ON hmso.classified_items(classified_at DESC);

-- ============================================================
-- TABLE 6: tasks
-- ============================================================
CREATE TABLE IF NOT EXISTS hmso.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    classified_item_id UUID REFERENCES hmso.classified_items(id),
    source_message_id UUID REFERENCES hmso.messages(id),
    title TEXT NOT NULL,
    description TEXT,
    assigned_to TEXT,
    assigned_by TEXT,
    group_name TEXT,
    status TEXT DEFAULT 'new',
    priority TEXT DEFAULT 'normal',
    deadline TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    completion_message_id UUID REFERENCES hmso.messages(id),
    days_without_response INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE hmso.tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view tasks"
  ON hmso.tasks FOR SELECT
  TO authenticated
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can insert tasks"
  ON hmso.tasks FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update tasks"
  ON hmso.tasks FOR UPDATE
  TO authenticated
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE INDEX IF NOT EXISTS idx_tasks_status ON hmso.tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_assigned ON hmso.tasks(assigned_to);

-- ============================================================
-- TABLE 7: directions
-- ============================================================
CREATE TABLE IF NOT EXISTS hmso.directions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_message_id UUID REFERENCES hmso.messages(id),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    topic TEXT,
    group_name TEXT,
    target_audience TEXT,
    is_still_valid BOOLEAN DEFAULT true,
    superseded_by UUID REFERENCES hmso.directions(id),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE hmso.directions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view directions"
  ON hmso.directions FOR SELECT
  TO authenticated
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can insert directions"
  ON hmso.directions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can update directions"
  ON hmso.directions FOR UPDATE
  TO authenticated
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE INDEX IF NOT EXISTS idx_directions_topic ON hmso.directions(topic);
CREATE INDEX IF NOT EXISTS idx_directions_valid ON hmso.directions(is_still_valid) WHERE is_still_valid = true;

-- ============================================================
-- TABLE 8: daily_briefings
-- ============================================================
CREATE TABLE IF NOT EXISTS hmso.daily_briefings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    briefing_date DATE NOT NULL UNIQUE,
    summary_text TEXT NOT NULL,
    new_tasks_count INTEGER DEFAULT 0,
    overdue_tasks_count INTEGER DEFAULT 0,
    completed_tasks_count INTEGER DEFAULT 0,
    new_directions_count INTEGER DEFAULT 0,
    sent_at TIMESTAMPTZ,
    sent_via TEXT DEFAULT 'whatsapp',
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE hmso.daily_briefings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view daily_briefings"
  ON hmso.daily_briefings FOR SELECT
  TO authenticated
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Authenticated users can insert daily_briefings"
  ON hmso.daily_briefings FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);

-- ============================================================
-- VIEW: overdue tasks (open > 3 days)
-- ============================================================
CREATE OR REPLACE VIEW hmso.overdue_tasks AS
SELECT
    t.*,
    m.message_text AS original_message,
    EXTRACT(DAY FROM now() - t.created_at) AS days_open
FROM hmso.tasks t
LEFT JOIN hmso.messages m ON m.id = t.source_message_id
WHERE t.status NOT IN ('done', 'cancelled')
AND t.created_at < now() - INTERVAL '3 days';

-- ============================================================
-- VIEW: today summary per group
-- ============================================================
CREATE OR REPLACE VIEW hmso.today_summary AS
SELECT
    g.name AS group_name,
    g.wa_group_id,
    COUNT(m.id) AS total_messages,
    COUNT(ci.id) FILTER (WHERE ci.classification = 'task') AS task_count,
    COUNT(ci.id) FILTER (WHERE ci.classification = 'direction') AS direction_count,
    COUNT(ci.id) FILTER (WHERE ci.classification = 'report') AS report_count
FROM hmso.groups g
LEFT JOIN hmso.messages m ON m.wa_group_id = g.wa_group_id
    AND m.timestamp >= CURRENT_DATE
LEFT JOIN hmso.classified_items ci ON ci.message_id = m.id
GROUP BY g.name, g.wa_group_id;

-- ============================================================
-- Grant table permissions
-- ============================================================
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA hmso TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA hmso TO anon;
GRANT ALL ON ALL TABLES IN SCHEMA hmso TO service_role;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA hmso TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA hmso TO service_role;
