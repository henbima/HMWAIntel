# chat/ — Module 6: Chat with Data + Knowledge Base

**Status:** Planned (Phase A full-text search infrastructure completed in Spec 001)
**Blueprint Reference:** HMSO Blueprint, Module 6

## Purpose

Search all WhatsApp messages + meeting transcripts using natural language. AI-powered Q&A that serves as "institutional memory" — enabling anyone to ask questions about what happened across the organization. Also serves as an onboarding tool for new employees.

## Planned Phases

### Phase A: Full-Text Search (DONE — Spec 001)
- `search_vector` tsvector column on `wa_intel.messages` (Indonesian config)
- GIN index for fast search
- `wa_intel.wa_intel__search_messages()` function

### Phase B: AI-Powered Q&A Edge Function
- Natural language question → full-text search → AI answers based on retrieved data
- Model: GPT-4o-mini
- Responds in Bahasa Indonesia, cites source group and date

### Phase C: Dashboard Chat Page
- Chat interface in React dashboard
- Text input + AI response display

### Phase D: Knowledge Base Features
- Topic tagging for directions
- Directions search page with filters (topic, date, store)
- "Onboarding Pack" generator: select store/role → compile relevant directions → AI summary → PDF export

### Phase E: Vector/Semantic Search (only if full-text insufficient)
- Supabase pgvector + OpenAI text-embedding-3-small
- Hybrid search (BM25 + vector)

## Related Specs

- Spec 001: HMSO Project Realignment (Phase A infrastructure)
- Future spec: Chat with Data Implementation (Phases B-E)

## Files (Planned)

- `search.ts` — Full-text search across all messages + meetings
- `chat-with-data.ts` — AI Q&A edge function
- `knowledge-base.ts` — Knowledge base query functions
