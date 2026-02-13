# Classification Redesign Proposal — From Per-Message to Per-Topic

**Author:** Cascade (AI) + Hendra Rusly  
**Date:** February 9, 2026  
**Status:** PROPOSAL — Awaiting review

---

## 1. The Problem: Why 15-Minute Batch Classification Fails

### How People Actually Use WhatsApp at HollyMart

WhatsApp group conversations do NOT follow neat 15-minute windows:

- **Morning burst (7-9 AM)**: Hendra/managers send tasks and directions
- **Scattered responses throughout the day**: "Ok siap" at 11 AM, photo proof at 4 PM
- **No reply threading**: Most users just type a new message — they don't use WhatsApp's reply feature. "Yang tadi soal retur sudah dikerjain" has no `quoted_message_id`
- **Multi-topic interleaving**: 3-4 different topics running simultaneously in one group
- **Late catch-up**: Managers review and respond at 10 PM to messages from 9 AM
- **Multi-day threads**: Task given Monday → "Besok ya" → Completed Wednesday

### Current System's Blind Spots

| Problem | Impact |
|---|---|
| **Reply-chain-only threading** (`quoted_message_id`) | ~70% of related messages are NOT connected via reply. They're treated as separate "conversations" |
| **30-minute conversation timeout** | Any conversation spanning > 30 min gets classified with incomplete context |
| **15-minute classification window** | Sees partial picture. Question at 9:00 and answer at 9:20 classified separately |
| **No reclassification** | Once classified, never re-evaluated even when new context arrives hours later |
| **Per-message classification** | Wastes AI tokens on "Ok", "Siap", "👍" — which need context to understand, not standalone classification |
| **Every run = partial view** | At 9:15 AM you see messages from 8:45 or earlier. The conversation might still be active until 10 AM |

### Example of How It Goes Wrong

```
GROUP: HollyMart Bima-1

8:02 AM — Hendra: "Andi, tolong cek harga kompetitor Indomie goreng hari ini"
8:03 AM — Andi: "Siap pak"
8:47 AM — Budi: "Stok minyak goreng tinggal 5 karton"
9:10 AM — Andi: "Pak sudah saya cek, Indomie goreng di Alfamart 3200, di kita 3500"
9:11 AM — Hendra: "Ok turunin jadi 3300. Hari ini ya"
9:45 AM — Andi: "Sudah diupdate pak, harga baru 3300"

CURRENT SYSTEM (classifying at 8:30 — 30 min timeout):
  ✗ 8:02 → classified as "task" (correct, but incomplete)
  ✗ 8:03 → classified as "noise" (WRONG — it's task acknowledgment)
  ✗ Misses the full conversation arc: task → ack → report → new direction → completion

PROPOSED SYSTEM (analyzing at end of day):
  ✓ Topic 1: "Cek harga kompetitor Indomie" (8:02-9:45)
     → Classification: task (completed)
     → Assigned to: Andi, by: Hendra
     → Result: Price adjusted to 3300
     → Status: DONE (Andi confirmed at 9:45)
  ✓ Topic 2: "Stok minyak goreng rendah" (8:47, standalone)
     → Classification: report
     → Priority: high (low stock alert)
```

---

## 2. Research: How Others Solve This

### Periskope's Approach

Periskope does NOT deeply classify every message. Instead:

1. **Real-time lightweight flagging**: As each message arrives, a fast check determines if it's "a question/query from external" → flag it
2. **Resolution tracking**: A flag is auto-resolved when an internal team member responds
3. **Human-in-the-loop**: Managers see flagged messages on dashboard, create tickets manually when needed
4. **No conversation threading at all** — they work at the per-message level but keep it simple

**Key insight: Flag first, classify later. Don't over-engineer per-message classification.**

### OpenClaw's Memory Architecture

OpenClaw uses a 3-tier memory system:

1. **Ephemeral memory** (`memory/YYYY-MM-DD.md`): Daily logs, append-only. Loaded at session start (today + yesterday)
2. **Durable memory** (`MEMORY.md`): Curated long-term facts, preferences, decisions
3. **Session memory**: Conversation transcripts, indexed and searchable via hybrid search (BM25 + vector)

**Key insight: Daily summaries as the primary memory artifact. The AI writes a daily log of what happened — not per-message metadata, but narrative context.**

### Academic NLP Research

WhatsApp group chat analysis research consistently finds:

- **Topic segmentation** (identifying which messages belong to which topic) is more valuable than per-message classification
- **Temporal context** matters enormously — messages 3 hours apart can be the same conversation
- **Speaker patterns** help: if A asks B a question, B's next message in the same group is likely the answer — even without reply threading

---

## 3. Proposed Architecture: "Collect → Segment → Classify → Brief"

### Overview

Replace the current "classify every 15 minutes" approach with a **two-layer system**:

```
LAYER 1: REAL-TIME TRIAGE (per message, as it arrives — NO AI cost)
├─ Keyword/pattern detection for urgent items
├─ Hendra instruction detection
├─ Question detection (heuristic)
└─ Store lightweight flags in message_flags table

LAYER 2: DAILY DEEP ANALYSIS (once per day, before briefing — AI-powered)
├─ Collect full day's messages per group
├─ AI topic segmentation: group related messages into topics
├─ Classify each topic (not each message)
├─ Track ongoing multi-day conversations
├─ Generate per-group summaries
└─ Compile daily briefing
```

### Layer 1: Real-Time Triage (No AI, Instant)

Runs as part of the Baileys listener or a lightweight DB trigger. Zero AI cost.

**Detection rules:**

| Flag Type | Detection Method | Example |
|---|---|---|
| `urgent` | Keywords: "urgent", "darurat", "segera", "ASAP", "kebakaran", "emergency" | "URGENT: stok habis!" |
| `hendra_instruction` | `is_from_hendra = true` + message length > 50 chars + imperative patterns | Hendra: "Tolong semua store manager..." |
| `question` | Ends with "?", or starts with "apa", "kapan", "dimana", "bagaimana", "kenapa", "siapa", "berapa" | "Kapan barang dari supplier datang?" |
| `low_stock` | Keywords: "stok habis", "tinggal X karton", "kosong", "out of stock" | "Minyak goreng tinggal 3" |
| `complaint` | Keywords: "komplain", "marah", "kecewa", "rusak", "expired" | "Customer komplain soal roti expired" |

**Purpose:** Catch time-sensitive items for potential real-time notification (Phase 2). Also pre-tags messages to help the daily analysis.

### Layer 2: Daily Deep Analysis (AI-Powered, Once Per Day)

Runs at **~6:00 AM WIB** (1 hour before the 7 AM briefing), analyzing the previous day's messages.

#### Step 1: Collect Full Day's Messages Per Group

```
For each active group:
  Fetch ALL messages from yesterday (00:00-23:59 WIB)
  Include: sender info, contact enrichment, timestamps, reply references, message_flags
  Sort chronologically
```

#### Step 2: AI Topic Segmentation

Instead of relying on reply chains, send the full day's conversation to AI and ask it to **identify distinct topics**:

```
PROMPT (Topic Segmentation):
"You are analyzing a day's worth of WhatsApp messages from a HollyMart group.
 
Group: {group_name}
Date: {date}
Messages: {all messages with timestamps, senders, roles}

Your job:
1. Identify distinct TOPICS discussed today (conversations about the same subject)
2. Group message numbers that belong to each topic
3. Messages can belong to multiple topics if they span topics
4. Consider: timing, sender patterns, content similarity, reply references
5. A response 3 hours later to a question IS part of the same topic
6. Short acknowledgments ("ok", "siap") belong to the topic they're responding to

Return JSON:
{
  "topics": [
    {
      "topic_id": 1,
      "label": "Cek harga kompetitor Indomie",
      "message_indices": [1, 3, 7, 12],
      "timespan": "08:02 - 09:45",
      "key_participants": ["Hendra", "Andi"]
    },
    ...
  ],
  "standalone_messages": [5, 8]  // messages that don't belong to any topic
}"
```

#### Step 3: Classify Each Topic

For each identified topic, classify it with FULL context (all related messages):

```
PROMPT (Topic Classification):
"Classify this complete topic/conversation from HollyMart group.

Topic: {label}
Group: {group_name}
Participants: {roles and names}
All messages in this topic:
{chronologically ordered messages}

Classify as: task / direction / report / question / coordination / noise

Additionally provide:
- summary: 1-2 sentence summary of the COMPLETE conversation arc
- outcome: what was the result? (e.g., "task completed", "question answered", "awaiting response")
- priority: urgent/high/normal/low
- action_needed: true/false — does someone still need to do something?
- assigned_to / assigned_by / deadline (if task)
- key_decisions: any decisions made in this conversation"
```

#### Step 4: Track Ongoing Conversations

Some topics don't conclude in one day. The system should track these:

- If a topic ends with an open question or pending task → mark as "ongoing"
- Next day's analysis checks for continuations of ongoing topics
- A "done" message on Day 3 gets connected back to the task from Day 1

#### Step 5: Generate Daily Briefing

Compile all topic classifications into the daily briefing. This briefing is now **topic-based**, not message-based:

```
📊 HollyMart Daily Brief — 8 Februari 2026

📈 Ringkasan Hari Ini:
• 15 grup aktif, 234 pesan, 18 topik teridentifikasi
• 4 task baru, 2 selesai, 1 overdue
• 1 arahan baru dari Hendra

🆕 Task Baru:
• [Bima-1] Cek harga kompetitor Indomie → @Andi
  ✅ SELESAI: Harga sudah diturunkan jadi 3300
• [Purchasing] Follow up supplier ikan Ramadan → @Dian
  ⏳ Menunggu: Supplier belum respon

⚠️ Butuh Perhatian:
• [Dompu] Stok minyak goreng rendah (5 karton) — belum ada yang follow up
• [Lombok-2] Customer komplain roti expired — sudah ditangani @Budi

📝 Arahan Hendra:
• [All Stores] Kebijakan baru: Semua retur expired harus difoto sebelum diproses
  → Disampaikan di grup HO, target: semua store manager

💬 Percakapan Aktif (belum selesai dari hari sebelumnya):
• [Bima-1] Jadwal shift lebaran — masih diskusi, belum final
• [Purchasing] Nego harga gula dari supplier baru — menunggu keputusan Hendra
```

---

## 4. Database Changes

### New Table: `wa_intel.message_flags`

Lightweight, real-time flags for urgent detection.

```sql
CREATE TABLE wa_intel.message_flags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID REFERENCES wa_intel.messages(id) ON DELETE CASCADE,
    flag_type TEXT NOT NULL,       -- 'urgent', 'question', 'hendra_instruction', 'low_stock', 'complaint'
    confidence REAL DEFAULT 1.0,   -- 1.0 for keyword match, lower for heuristic
    resolved_at TIMESTAMPTZ,
    resolved_by_message_id UUID REFERENCES wa_intel.messages(id),
    flagged_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_message_flags_type ON wa_intel.message_flags(flag_type);
CREATE INDEX idx_message_flags_unresolved ON wa_intel.message_flags(flag_type) WHERE resolved_at IS NULL;
```

### New Table: `wa_intel.daily_topics`

One row per identified topic per day.

```sql
CREATE TABLE wa_intel.daily_topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES wa_intel.groups(id),
    topic_date DATE NOT NULL,
    topic_label TEXT NOT NULL,              -- AI-generated label
    message_ids UUID[] NOT NULL,            -- Array of message IDs in this topic
    classification TEXT,                     -- task / direction / report / question / coordination / noise
    summary TEXT,                            -- AI-generated summary of full conversation
    outcome TEXT,                            -- "completed", "pending", "answered", "ongoing"
    priority TEXT DEFAULT 'normal',
    action_needed BOOLEAN DEFAULT false,
    assigned_to TEXT,
    assigned_by TEXT,
    deadline TEXT,
    deadline_parsed TIMESTAMPTZ,
    key_decisions TEXT[],                    -- Array of decisions made
    is_ongoing BOOLEAN DEFAULT false,        -- Continues to next day?
    continued_from UUID REFERENCES wa_intel.daily_topics(id),  -- Link to previous day's topic
    ai_model TEXT,
    analyzed_at TIMESTAMPTZ DEFAULT now(),
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_daily_topics_date ON wa_intel.daily_topics(topic_date DESC);
CREATE INDEX idx_daily_topics_class ON wa_intel.daily_topics(classification);
CREATE INDEX idx_daily_topics_ongoing ON wa_intel.daily_topics(is_ongoing) WHERE is_ongoing = true;
CREATE INDEX idx_daily_topics_action ON wa_intel.daily_topics(action_needed) WHERE action_needed = true;
```

### Keep Existing Tables

- `classified_items` — keep for backward compatibility, but stop populating with per-message data
- `tasks` — keep, but populate from `daily_topics` where `classification = 'task'`
- `directions` — keep, but populate from `daily_topics` where `classification = 'direction'`

---

## 5. Cron Schedule Changes

| Job | Current | Proposed |
|---|---|---|
| `classify-messages` | Every 15 min (FAILING) | **DISABLE** — replaced by analyze-daily |
| `analyze-daily` | N/A | **NEW** — Run at 6:00 AM WIB (23:00 UTC previous day) |
| `daily-briefing` | Daily midnight UTC | Keep at 7:00 AM WIB (00:00 UTC) — now uses daily_topics data |

---

## 6. Cost Comparison

| Metric | Current (15-min batch) | Proposed (daily analysis) |
|---|---|---|
| AI calls per day | ~96 calls × N conversations | ~15 calls (1 per active group) |
| Tokens per call | Small (1-5 messages) | Larger (50-200 messages per group) | 
| Total tokens/day | Scattered, often redundant | ~2-3x less total (no noise classification) |
| Classification quality | Low (partial context) | High (full day context) |
| Latency for urgent items | 15-30 min | Real-time (Layer 1 triage) |
| Daily briefing quality | Low (fragmented topics) | High (complete conversation arcs) |

---

## 7. Implementation Phases

### Phase A: Fix Immediate Issues (1 day)
1. Disable broken cron jobs (classify-messages, daily-briefing)
2. Create `message_flags` table
3. Add basic triage logic to listener or as a lightweight DB function

### Phase B: Build Daily Analysis (2-3 days)
1. Create `daily_topics` table
2. Build `analyze-daily` Edge Function with topic segmentation + classification
3. Test with a few groups manually
4. Schedule cron at 6 AM WIB

### Phase C: Upgrade Daily Briefing (1 day)
1. Modify daily briefing to use `daily_topics` instead of `classified_items`
2. Topic-based briefing format (see Section 3, Step 5)
3. Schedule at 7 AM WIB

### Phase D: Ongoing Conversation Tracking (1-2 days)
1. Implement `is_ongoing` + `continued_from` logic
2. Daily analysis checks for continuations of previous day's ongoing topics
3. Add "Active Conversations" section to briefing

### Phase E: Dashboard Updates (2-3 days)
1. Topic-based view instead of per-message classification view
2. Daily timeline showing topics per group
3. Ongoing conversations tracker

---

## 8. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| AI topic segmentation inaccurate | Start with groups that have <100 messages/day. Iterate prompt. Human review. |
| Large groups = too many tokens | Split into time windows (morning/afternoon/evening) for large groups |
| Urgent items missed until next day | Layer 1 real-time triage catches these immediately |
| AI cost increases with full-day context | Use GPT-4o-mini for segmentation (cheap). Full classification only for non-noise topics. |
| Multi-day topic tracking is complex | Start simple: just mark as "ongoing". Manual review on dashboard. |

---

## 9. Summary: Why This Is Better

**Current system asks:** "What type is this message?" (with 15 minutes of context)

**Proposed system asks:** "What happened in this group today?" (with full day of context)

This aligns with how Hendra actually wants to use the system — he doesn't want to classify 500 messages. He wants to know:
1. What tasks were given today? Which are done?
2. What needs my attention?
3. What directions did I give?
4. Are there any open issues?

The daily briefing becomes dramatically more useful because it tells a **story**, not a list of fragmented classifications.
