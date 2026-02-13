-- Migration: Register new DB objects in hm_core.object_registry
-- Purpose: Ensure all new HMSO objects are tracked for multi-app boundary governance
-- Spec: 001 HMSO Project Realignment — Task 4.4
-- Date: 2026-02-15
-- Note: object_registry check constraint only allows: table, function, schema, cron_job, edge_function
--       Indexes are not registerable — they are implicitly owned by their parent table's owner.

-- Register meetings table
INSERT INTO hm_core.object_registry (object_type, object_name, object_schema, owner_app, description)
VALUES ('table', 'meetings', 'wa_intel', 'wa_intel', 'Full meeting records — Zoom transcripts, executive summaries, key decisions')
ON CONFLICT DO NOTHING;

-- Register search function
INSERT INTO hm_core.object_registry (object_type, object_name, object_schema, owner_app, description)
VALUES ('function', 'wa_intel__search_messages', 'wa_intel', 'wa_intel', 'Full-text search across messages using Indonesian tsvector')
ON CONFLICT DO NOTHING;
