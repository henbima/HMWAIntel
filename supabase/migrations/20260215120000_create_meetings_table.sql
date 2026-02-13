-- Migration: Create wa_intel.meetings table
-- Purpose: Store full meeting records (Zoom transcripts, executive summaries, key decisions)
-- Spec: 001 HMSO Project Realignment — Task 4.1
-- Date: 2026-02-15

-- Create meetings table
CREATE TABLE IF NOT EXISTS wa_intel.meetings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zoom_meeting_id TEXT,
    title TEXT NOT NULL,
    meeting_date TIMESTAMPTZ NOT NULL,
    duration_minutes INTEGER,
    participants TEXT[],
    total_chunks INTEGER,
    executive_summary TEXT,
    raw_transcript TEXT,
    key_decisions JSONB,
    source TEXT DEFAULT 'zoom',
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_meetings_date
    ON wa_intel.meetings(meeting_date DESC);

CREATE INDEX IF NOT EXISTS idx_meetings_zoom_id
    ON wa_intel.meetings(zoom_meeting_id)
    WHERE zoom_meeting_id IS NOT NULL;

-- Enable RLS
ALTER TABLE wa_intel.meetings ENABLE ROW LEVEL SECURITY;

-- RLS Policy (idempotent via DROP IF EXISTS + CREATE)
DROP POLICY IF EXISTS "Authenticated users can read meetings" ON wa_intel.meetings;
CREATE POLICY "Authenticated users can read meetings"
    ON wa_intel.meetings FOR SELECT TO authenticated USING (true);

-- Grants
GRANT SELECT, INSERT, UPDATE ON wa_intel.meetings TO authenticated;
GRANT SELECT ON wa_intel.meetings TO anon;
GRANT ALL ON wa_intel.meetings TO service_role;
