-- Migration: Add multi-source columns to wa_intel.messages
-- Purpose: Enable source-agnostic message storage (WhatsApp, meetings, future channels)
-- Spec: 001 HMSO Project Realignment — Task 4.2
-- Date: 2026-02-15

-- Add source_type column (defaults to 'whatsapp' for all existing rows)
ALTER TABLE wa_intel.messages
    ADD COLUMN IF NOT EXISTS source_type TEXT NOT NULL DEFAULT 'whatsapp';

-- Add meeting_id FK column (references meetings table created in previous migration)
ALTER TABLE wa_intel.messages
    ADD COLUMN IF NOT EXISTS meeting_id UUID REFERENCES wa_intel.meetings(id);

-- Add meeting_metadata column for chunk info
ALTER TABLE wa_intel.messages
    ADD COLUMN IF NOT EXISTS meeting_metadata JSONB;

-- Index on source_type for filtering by source
CREATE INDEX IF NOT EXISTS idx_messages_source_type
    ON wa_intel.messages(source_type);

-- Partial index on meeting_id (only non-null values)
CREATE INDEX IF NOT EXISTS idx_messages_meeting_id
    ON wa_intel.messages(meeting_id)
    WHERE meeting_id IS NOT NULL;
