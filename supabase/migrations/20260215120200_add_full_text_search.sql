-- Migration: Add full-text search to wa_intel.messages
-- Purpose: Enable text search across messages for Chat-with-Data feature
-- Spec: 001 HMSO Project Realignment — Task 4.3
-- Date: 2026-02-15

-- Add generated tsvector column for full-text search
ALTER TABLE wa_intel.messages
    ADD COLUMN IF NOT EXISTS search_vector tsvector
    GENERATED ALWAYS AS (
        to_tsvector('indonesian', coalesce(message_text, '') || ' ' || coalesce(sender_name, ''))
    ) STORED;

-- GIN index for fast full-text search
CREATE INDEX IF NOT EXISTS idx_messages_search
    ON wa_intel.messages USING GIN (search_vector);

-- Search function (no dollar-quoting — MCP compatible)
CREATE OR REPLACE FUNCTION wa_intel.wa_intel__search_messages(query text, limit_count int DEFAULT 50)
RETURNS TABLE(
    id uuid,
    message_text text,
    sender_name text,
    group_name text,
    "timestamp" timestamptz,
    relevance real
)
LANGUAGE plpgsql
SECURITY DEFINER
AS '
BEGIN
    RETURN QUERY
    SELECT
        m.id,
        m.message_text,
        m.sender_name,
        g.name AS group_name,
        m.timestamp,
        ts_rank(m.search_vector, websearch_to_tsquery(''indonesian'', query)) AS relevance
    FROM wa_intel.messages m
    LEFT JOIN wa_intel.groups g ON m.group_id = g.id
    WHERE m.search_vector @@ websearch_to_tsquery(''indonesian'', query)
    ORDER BY relevance DESC
    LIMIT limit_count;
END;
';
