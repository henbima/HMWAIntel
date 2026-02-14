# meetings/ — Module 7: Meeting Transcript Ingestion

**Status:** Planned
**Blueprint Reference:** HMSO Blueprint, Module 7

## Purpose

Automatically capture, chunk, summarize, and ingest meeting transcripts into the HMSO pipeline. Meeting transcripts are the highest-density signal source in the organization — decisions, tasks, and policies discussed in coordination meetings (Rapat Koordinasi Bulanan, etc.) that would otherwise be trapped in people's memory.

## Planned Tech Stack

- n8n (self-hosted on VPS) for workflow orchestration
- Zoom API webhook for automatic transcript capture
- OpenRouter (Claude Sonnet / GPT-4o) for premium AI summarization
- Supabase `wa_intel.meetings` table for storage

## Planned Flow

1. Zoom meeting ends → webhook triggers n8n workflow
2. n8n fetches full transcript from Zoom API
3. Meeting record inserted into `wa_intel.meetings`
4. Transcript chunked into 30-min segments (with 2-min overlap)
5. Each chunk summarized by premium AI model
6. Chunks inserted into `wa_intel.messages` with `source_type='meeting'`
7. Standard classification pipeline processes meeting chunks

## Related Specs

- Spec 001: HMSO Project Realignment (created `wa_intel.meetings` table, added `source_type` to messages)
- Future spec: Meeting Ingestion Implementation (n8n workflow, Zoom integration)

## Files (Planned)

- `chunk-transcript.ts` — Split transcript into 30-min segments
- `summarize-chunk.ts` — AI summarization via OpenRouter
- `ingest-meeting.ts` — Insert chunks into messages table
- `manual-upload.ts` — Manual upload path for offline meetings
