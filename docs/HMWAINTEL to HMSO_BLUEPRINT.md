# HMSO_BLUEPRINT.md
# HMSO — HollyMart Signal Operations — Complete Context Document

> **INSTRUKSI UNTUK AI (Claude Code / Cursor):**
> Baca dokumen ini SELURUHNYA sebelum menulis kode apapun.
> Dokumen ini adalah "North Star" untuk project ini.
> Semua keputusan arsitektur sudah final — JANGAN suggest alternatif kecuali diminta.
> Jika ada ambiguitas, rujuk ke bagian "Decisions Already Made" di bawah.

---

## 0) PROJECT IDENTITY

- **Nama project:** HMSO — HollyMart Signal Operations
- **Internal codename (database schema):** `wa_intel` (legacy name, may migrate to `hmso` later)
- **Owner:** Hendra Rusly — CEO & Lead Developer, HollyMart
- **Status:** ✅ OPERATIONAL — Listener running 24/7 on VPS (Biznet NEO Lite), 18,500+ messages captured, 299 groups synced, 11,900+ contacts auto-discovered.

### One-liner
The organizational nervous system that captures, classifies, and routes actionable signals from every communication channel across HollyMart.

### What It Does
HMSO transforms unstructured communication — WhatsApp messages across 250+ groups, meeting transcripts, and future channels — into structured, actionable intelligence. It listens to the entire organization in real-time, separates signal from noise, and ensures that no task, directive, or decision falls through the cracks.

### Why It Exists
HollyMart operates across multiple cities (Bima, Dompu, Lombok) with hundreds of WhatsApp groups and regular coordination meetings. Critical directives, tasks, and decisions get buried in daily chatter or lost in people's memory. When staff rotate or resign, institutional knowledge disappears with them. HMSO solves this by making organizational communication captured, classified, searchable, and accountable — in line with HOS v1 §6: "If it's not written, it didn't happen."

### Core Pipeline
1. **Capture** → Ingest raw communication from all sources (WhatsApp via Baileys, Zoom transcripts via n8n, future: email, HMCS notes)
2. **Classify** → AI-powered categorization of every message: tasks, directives, decisions, escalations, or routine chatter
3. **Surface** → Deliver daily executive briefings, power a real-time dashboard, and enable natural language search across all organizational communication
4. **Archive** → Build a persistent, searchable knowledge base that survives personnel changes and preserves institutional memory

### How It Fits the HM Ecosystem

| System | Function |
|---|---|
| **HMCS** | Runs the operation (Central System) |
| **HMLS** | Trains the people (Learning System) |
| **HMBI** | Reads the numbers (Business Intelligence) |
| **HMSO** | Hears the organization (Signal Operations) |

HMBI tells you what the data says. HMSO tells you what the people say. Together they provide complete organizational awareness.

### Design Principles
- **Source-agnostic pipeline** — adding a new communication channel means adding a new input, not rebuilding the system
- **AI-first classification** — humans review what matters, not everything
- **Zero-loss capture** — every message is stored, even if classified as routine, because today's chatter may be tomorrow's evidence
- **HOS v1 aligned** — built for compliance, repeatability, and measurable outcomes

### Hubungan dengan HMCS
HMSO dan HMCS berada di **database Supabase yang sama** (schema berbeda). HMCS sudah digunakan tim sehari-hari dan memiliki API. HMSO adalah feeder — data mengalir satu arah: HMSO → HMCS. Tim tidak perlu tahu HMSO ada — mereka cukup melihat task dan briefing muncul di HMCS.

### Ini BUKAN:
chatbot, auto-reply, marketing tool, atau pengganti HMCS.

### Ini ADALAH:
Source-agnostic intelligence pipeline yang mengubah chaos komunikasi organisasi menjadi data terstruktur yang dapat di-route ke HMCS.

---

## 1) NORTH STAR & PROBLEM STATEMENT

### Masalah yang Diselesaikan

HollyMart memiliki 15+ WhatsApp group (toko Bima, Dompu, Lombok, purchasing, HO, dll). Pain points:

1. **Task tenggelam di chat** — Task, arahan, dan info penting tercampur dengan chit-chat dan tenggelam dalam ratusan pesan harian.
2. **Task tanpa accountability** — Task diberikan tapi tidak ada konfirmasi selesai. Kadang dikerjakan tanpa laporan, kadang tidak dikerjakan sama sekali.
3. **Knowledge hilang saat PIC ganti** — Arahan & memo panjang dari Hendra tidak ter-transfer ke orang baru dengan kualitas yang sama.
4. **Leader overwhelmed** — Hendra sendiri tidak mau buka WhatsApp lagi karena volume terlalu besar. Ini bottleneck.
5. **Tidak ada visibility** — Tidak ada dashboard atau visual overview tentang apa yang sedang terjadi di semua grup sekaligus.

### Alignment dengan HOS v1 (Hendra Operating System)

| Pain Point | HOS v1 Principle yang Dilanggar |
|---|---|
| Task tenggelam | §7 — "WA is for coordination, not operations" |
| Tidak ada accountability | §6 — "No record = no decision" / "Decision logs > verbal alignment" |
| Knowledge hilang | §3 — "Rules > Memory" — "If it must be remembered, it will be missed" |
| Leader bottleneck | §10 — "Decisions don't bottleneck at you" |
| Tidak ada visibility | §9 — "Measurable + Auditable" |

### 4 Kemampuan Inti (Source-Agnostic)

1. **CAPTURE** — Ingest raw communication dari semua sumber. WhatsApp via Baileys (read-only, nomor cadangan). Meeting transcripts via n8n/Make.com (Zoom webhook). Future: email, HMCS notes, voice memos.
2. **CLASSIFY** — AI kategorisasi setiap pesan/segment: Task / Arahan / Keputusan / Laporan / Eskalasi / Noise. Extract entities: siapa assign ke siapa, deadline, topik. Same classifier, any source.
3. **SURFACE** — Daily briefing setiap pagi (WA to self) + visual dashboard (kanban, activity, search) + chat-with-data (AI Q&A). HMCS integration for team delivery.
4. **ARCHIVE** — Knowledge base yang searchable. Arahan, keputusan rapat, & memo tersimpan permanen. Onboarding orang baru = instant. Personnel changes don't destroy institutional memory.

---

## 2) DECISIONS ALREADY MADE (FINAL — DO NOT CHANGE)

Berikut keputusan arsitektur yang sudah diambil melalui diskusi mendalam. JANGAN suggest alternatif.

| Keputusan | Pilihan | Alasan |
|---|---|---|
| **Project name** | HMSO — HollyMart Signal Operations | Source-agnostic. Part of HM ecosystem (HMCS, HMLS, HMBI, HMSO). |
| **Database schema** | `wa_intel` (legacy, may migrate to `hmso` later) | Schema sudah ada dan operational. Rename nanti. Kode boleh pakai alias/constant. |
| **Pipeline design** | Source-agnostic: Capture → Classify → Surface → Archive | Adding new input source = adding new ingestion module, NOT rebuilding pipeline. |
| **WA Gateway** | Baileys (@whiskeysockets/baileys) | Open source, TypeScript, no browser needed, community besar |
| **Meeting transcript ingestion** | n8n (self-hosted on VPS) or Make.com | Zoom webhook → chunk transcript → AI summarize → INSERT to database. n8n preferred (already have VPS). |
| **Meeting transcript AI** | Premium model via OpenRouter (Claude Sonnet / GPT-4o) | Meeting summaries need high quality. WhatsApp classification uses GPT-4o-mini (cheaper, higher volume). |
| **Meeting chunk size** | 30 minutes default, with ~2 min overlap | 15 min too granular (splits discussions). 30 min captures full topic arcs. Overlap preserves context continuity. |
| **Database** | Supabase — **project HMCS yang sudah ada**, schema `wa_intel` | Same database = HMCS can read directly. Zero integration cost. |
| **Baileys runner** | VPS (Biznet NEO Lite, Rp 59,000/bulan) — managed by PM2 | 24/7 uptime, tidak tergantung PC kantor menyala. |
| **AI Classifier** | OpenAI GPT-4o-mini (via Supabase Edge Function) | Cost efficient for high-volume WA messages. Already deployed. |
| **Dashboard** | React (built via Bolt.new) + Supabase Auth | Already deployed. Kanban, directions, contacts, groups, briefings. |
| **RAG / Knowledge Base** | PostgreSQL full-text search (Phase 1) → pgvector (Phase 2) | Full-text search dulu. pgvector hanya jika perlu semantic search. |
| **Nomor WhatsApp** | Nomor cadangan / backup — read-only listener | Mitigasi risiko ban. Listener TIDAK mengirim pesan (kecuali 1 briefing/hari). |
| **Daily briefing delivery** | WhatsApp to self (nomor cadangan kirim ke nomor utama Hendra) | 1 pesan/hari ke diri sendiri = risiko ban negligible. |
| **Future task delivery ke tim** | Via HMCS (bukan WhatsApp bot) | HMCS sudah digunakan tim sehari-hari dan punya API. HOS §7 compliance. |
| **HMCS Integration** | Same database, direct read (Pattern A) → API push (Pattern B) nanti | wa_intel dan HMCS di database yang sama. HMCS bisa query langsung. |
| **BUKAN OpenClaw** | Rejected | Security risk (shell access), single-user design, no dashboard. Detail: Section 16. |
| **BUKAN Periskope (SaaS)** | Rejected | Vendor dependency, $15/seat/mo, limited knowledge base. |
| **BUKAN Telegram/Email** | Rejected sebagai delivery channel | Tim tidak pakai Telegram. Jarang buka email. Operasi di WA + HMCS. |

---

## 3) ARCHITECTURE OVERVIEW

```
┌──────────────────────────────────────────────────────────────────┐
│              HMSO — HollyMart Signal Operations                   │
│              "The organizational nervous system"                  │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  INPUT SOURCES (Capture)                                          │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐             │
│  │  WhatsApp    │ │    Zoom      │ │   Future:    │             │
│  │  250+ groups │ │  Meetings    │ │  Email, HMCS │             │
│  │  (Baileys)   │ │  (n8n)       │ │  notes, etc  │             │
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘             │
│         │                │                │                      │
│         ▼                ▼                ▼                      │
│  ┌──────────────────────────────────────────────────────┐       │
│  │  Supabase Database — schema: wa_intel                 │       │
│  │  messages (source_type: 'whatsapp' | 'meeting')       │       │
│  │  meetings (full transcripts + executive summaries)    │       │
│  │  classified_items | tasks | directions                │       │
│  │  daily_briefings | contacts | groups                  │       │
│  └───────────────────────┬──────────────────────────────┘       │
│                          │                                       │
│  INTELLIGENCE LAYER      │                                       │
│  ┌───────────┐ ┌────────┴───────┐ ┌───────────┐               │
│  │ Classify  │ │ Daily Briefing │ │ Chat w/   │               │
│  │ (Edge Fn) │ │ (pg_cron)      │ │ Data (AI) │               │
│  │ GPT-4o-   │ │                │ │           │               │
│  │ mini      │ │                │ │           │               │
│  └───────────┘ └────────────────┘ └───────────┘               │
│                                                                   │
│  OUTPUT LAYER                                                     │
│  ┌───────────┐ ┌────────────────┐ ┌───────────┐               │
│  │ Dashboard │ │ WhatsApp Brief │ │   HMCS    │               │
│  │ (React)   │ │ (to Hendra)    │ │ (team)    │               │
│  │ admin use │ │ 1x/day         │ │ API ready │               │
│  └───────────┘ └────────────────┘ └───────────┘               │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

### Data Flow — WhatsApp Source

```
[WhatsApp Groups 250+]
    │
    ▼ (Baileys WebSocket — nomor cadangan, READ-ONLY)
[Baileys Listener — VPS Biznet NEO Lite, PM2]
    │
    ▼ (INSERT with source_type='whatsapp')
[Supabase — wa_intel.messages]
    │
    ▼ (pg_cron every 15 min)
[AI Classifier — Edge Function, GPT-4o-mini]
    │ → classified_items, tasks, directions
    │
    ├──▶ Daily Briefing (pg_cron 7am) → WhatsApp to Hendra
    ├──▶ Dashboard (React) → Kanban, search, analytics
    ├──▶ Chat with Data (Edge Function) → AI Q&A
    └──▶ HMCS (same database) → team sees tasks
```

### Data Flow — Meeting Transcript Source

```
[Zoom Meeting Ends]
    │
    ▼ (Zoom webhook)
[n8n Workflow on VPS]
    │
    ├─ 1. Receive full transcript from Zoom
    │
    ├─ 2. Chunk into 30-min segments (with 2-min overlap)
    │
    ├─ 3. For each chunk: AI summarize via OpenRouter (premium model)
    │     Extract: decisions, tasks, directions, open questions
    │
    ├─ 4. INSERT chunk summaries into wa_intel.messages
    │     (source_type='meeting', meeting_metadata={...})
    │
    ├─ 5. INSERT full record into wa_intel.meetings
    │     (raw transcript + executive summary + metadata)
    │
    └─ 6. Existing pipeline takes over automatically
          Classifier → Tasks → Briefing → Dashboard → HMCS
```

### Full System Architecture (HMSO + HMCS)

```
┌─────────────────────────────────────────────────────┐
│           INPUT SOURCES                              │
│  WhatsApp (250+ groups)    Zoom Meetings             │
│  via Baileys (read-only)   via n8n (webhook)         │
│  Future: Email, HMCS notes, voice memos              │
└──────────────┬─────────────────────┬────────────────┘
               │                     │
               ▼                     ▼
┌─────────────────────────────────────────────────────┐
│          Supabase (shared database)                  │
│                                                      │
│  ┌──────────────────┐    ┌────────────────────────┐ │
│  │  wa_intel schema  │    │    hmcs schema         │ │
│  │  (HMSO data)      │    │    (public)            │ │
│  │                   │    │                        │ │
│  │  messages ────────│───▶│  tasks (future)        │ │
│  │  meetings         │    │  notifications         │ │
│  │  classified_items │───▶│  employee dashboard    │ │
│  │  tasks            │    │                        │ │
│  │  directions       │    │  API available ✅       │ │
│  │  daily_briefings  │    │  Team uses daily ✅     │ │
│  │  contacts         │    │                        │ │
│  └──────────────────┘    └────────────────────────┘ │
│         │                                            │
│  Edge Functions:                                     │
│  - classify-messages (every 15 min)                  │
│  - generate-briefing (daily 7am)                     │
│  - chat-with-data (on demand)                        │
│  - sync-to-hmcs (future)                             │
└─────────┬──────────────────────────┬────────────────┘
          │                          │
          ▼                          ▼
   ┌──────────────┐        ┌──────────────────┐
   │ HMSO          │        │ HMCS             │
   │ Dashboard     │        │ (team daily use) │
   │ (Hendra/admin)│        │ Has API ✅        │
   └──────────────┘        └──────────────────┘
          │
          ▼
   ┌──────────────┐
   │ WhatsApp     │
   │ Daily Brief  │
   │ (secondary → │
   │  primary #)  │
   └──────────────┘
```


---

## 4) TECH STACK

| Layer | Technology | Version | Status | Notes |
|---|---|---|---|---|
| **INPUT: WhatsApp** | `@whiskeysockets/baileys` | v7.x | ✅ Running | Read-only listener, WebSocket-based |
| **INPUT: Meetings** | n8n (self-hosted on VPS) | Latest | 📋 Next | Zoom webhook → chunk → summarize → insert |
| **Meeting AI** | OpenRouter (Claude Sonnet / GPT-4o) | — | 📋 Next | Premium model for long transcript summarization |
| Runtime (Baileys) | Node.js on VPS | v18+ | ✅ Running | Biznet NEO Lite, managed by PM2 |
| Database | Supabase (PostgreSQL) | Existing HMCS project | ✅ Running | Schema: `wa_intel`, 8+ tables |
| AI Classifier | GPT-4o-mini via Supabase Edge Function | — | ✅ Deployed | Classifies messages from ALL sources |
| Daily Briefing | Supabase Edge Function | — | ✅ Deployed | Generates Bahasa Indonesia summary |
| Dashboard | React + Supabase Auth | — | ✅ Deployed | Built via Bolt.new |
| Full-text Search | PostgreSQL tsvector/tsquery | — | 🔜 Coming | `to_tsvector('indonesian', ...)` |
| Chat with Data | Edge Function + AI Q&A | — | 🔜 Coming | Search → context → AI answer |
| HMCS Integration | Same DB direct read / HMCS API | — | 📋 Planned | Pattern A (direct) → Pattern B (API) |
| WA Briefing Delivery | Baileys send (secondary → primary) | — | 📋 Planned | 1 msg/day, negligible ban risk |
| Vector Search | Supabase pgvector | — | 📋 Future | Only if full-text search insufficient |

### AI Model Strategy (Two-Tier)

| Use Case | Model | Why | Est. Cost |
|---|---|---|---|
| WhatsApp classification (high volume, short messages) | GPT-4o-mini | Cheap, fast, good enough for short texts | ~$1-3/mo |
| Meeting transcript summarization (low volume, long text) | Claude Sonnet or GPT-4o via OpenRouter | Premium quality needed for 3000-5000 word chunks | ~$2-5/mo |
| Chat-with-data Q&A | GPT-4o-mini | Short answers from retrieved context | ~$1-2/mo |
| **Total AI cost** | | | **~$4-10/mo** |

### Running Cost

| Item | Cost | Notes |
|---|---|---|
| Supabase | **$0** | Pakai project HMCS existing, schema baru |
| AI API (OpenAI + OpenRouter) | **$4-10/mo** | Two-tier: mini for WA, premium for meetings |
| VPS (Biznet NEO Lite) | **Rp 59,000/mo** | Listener + n8n, both on same VPS |
| **Total** | **~Rp 130-220k/mo** | |

### Current Metrics (as of Feb 9, 2026)

| Metric | Count |
|---|---|
| Messages captured | 18,567+ |
| Contacts auto-discovered | 11,915 |
| Groups synced | 299 |
| Group memberships | 4,906+ |
| Messages classified (test) | 30 |
| Meeting transcripts ingested | 0 (module not built yet) |

---

## 5) DATABASE SCHEMA

Semua tabel berada di schema `wa_intel` dalam Supabase project HMCS yang sudah ada.

```sql
-- ============================================
-- SCHEMA: wa_intel
-- HMSO — HollyMart Signal Operations System
-- ============================================

CREATE SCHEMA IF NOT EXISTS wa_intel;

-- ============================================
-- TABLE 1: groups
-- Daftar WhatsApp groups yang di-monitor
-- ============================================
CREATE TABLE wa_intel.groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wa_group_id TEXT UNIQUE NOT NULL,        -- WhatsApp group JID (e.g., "120363xxx@g.us")
    name TEXT NOT NULL,                       -- Nama grup (e.g., "HollyMart Bima-1")
    description TEXT,
    is_active BOOLEAN DEFAULT true,           -- Apakah masih di-monitor
    participant_count INTEGER,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- TABLE 2: contacts
-- Registry orang-orang HollyMart — siapa mereka, apa jabatannya
-- AI classifier MEMBUTUHKAN data ini untuk konteks
-- ============================================
CREATE TABLE wa_intel.contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wa_jid TEXT UNIQUE NOT NULL,              -- WhatsApp JID (e.g., "628123456789@s.whatsapp.net")
    phone_number TEXT,                        -- Nomor HP bersih (e.g., "628123456789")
    display_name TEXT NOT NULL,               -- Nama lengkap (e.g., "Budi Santoso")
    short_name TEXT,                          -- Nama panggilan (e.g., "Budi")
    role TEXT,                                -- Jabatan (e.g., "Store Manager", "Kasir", "Purchasing Staff")
    location TEXT,                            -- Lokasi (e.g., "Bima-1", "Dompu", "HO Lombok")
    department TEXT,                          -- Departemen (e.g., "Operations", "Purchasing", "HRD")
    is_leadership BOOLEAN DEFAULT false,      -- Apakah level manajerial ke atas
    is_active BOOLEAN DEFAULT true,           -- Masih aktif kerja di HollyMart
    hmcs_employee_id TEXT,                    -- (OPSIONAL) Link ke tabel karyawan di schema public (HMCS)
    notes TEXT,                               -- Catatan tambahan
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_contacts_jid ON wa_intel.contacts(wa_jid);
CREATE INDEX idx_contacts_location ON wa_intel.contacts(location);

-- ============================================
-- TABLE 3: group_members
-- Siapa saja anggota tiap grup — many-to-many
-- ============================================
CREATE TABLE wa_intel.group_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID REFERENCES wa_intel.groups(id) ON DELETE CASCADE,
    contact_id UUID REFERENCES wa_intel.contacts(id) ON DELETE CASCADE,
    wa_role TEXT DEFAULT 'member',            -- 'admin' / 'superadmin' / 'member'
    joined_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(group_id, contact_id)
);

-- ============================================
-- TABLE 4: messages
-- Raw messages dari SEMUA sumber — WhatsApp, meeting transcripts, future channels
-- ============================================
CREATE TABLE wa_intel.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_type TEXT NOT NULL DEFAULT 'whatsapp',  -- 'whatsapp' / 'meeting' / future: 'email', 'hmcs_note'
    wa_message_id TEXT UNIQUE,                -- WhatsApp message ID (null for non-WA sources)
    group_id UUID REFERENCES wa_intel.groups(id),
    wa_group_id TEXT,                         -- WhatsApp group JID (null for non-WA sources)
    sender_jid TEXT,                          -- Sender WhatsApp JID (null for non-WA sources)
    sender_name TEXT,                         -- Push name / display name / speaker name
    contact_id UUID REFERENCES wa_intel.contacts(id),
    message_text TEXT,                        -- Isi pesan (teks) atau chunk summary (meeting)
    message_type TEXT DEFAULT 'text',         -- text / image / video / audio / document / sticker / meeting_chunk
    media_url TEXT,                           -- URL media jika ada
    is_from_hendra BOOLEAN DEFAULT false,     -- Flag: apakah pesan/keputusan dari Hendra
    quoted_message_id TEXT,                   -- Jika reply ke pesan lain (WA only)
    meeting_id UUID REFERENCES wa_intel.meetings(id),  -- Link ke meeting record (meeting source only)
    meeting_metadata JSONB,                   -- { chunk_index, total_chunks, start_time, end_time, speakers[] }
    timestamp TIMESTAMPTZ NOT NULL,           -- Waktu pesan dikirim / meeting chunk timestamp
    raw_data JSONB,                           -- Raw message object (Baileys for WA, transcript chunk for meeting)
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Index untuk query umum
CREATE INDEX idx_messages_group_time ON wa_intel.messages(wa_group_id, timestamp DESC);
CREATE INDEX idx_messages_sender ON wa_intel.messages(sender_jid);
CREATE INDEX idx_messages_from_hendra ON wa_intel.messages(is_from_hendra) WHERE is_from_hendra = true;
CREATE INDEX idx_messages_timestamp ON wa_intel.messages(timestamp DESC);
CREATE INDEX idx_messages_source_type ON wa_intel.messages(source_type);
CREATE INDEX idx_messages_meeting_id ON wa_intel.messages(meeting_id) WHERE meeting_id IS NOT NULL;

-- ============================================
-- TABLE 4b: meetings
-- Full meeting records — one row per Zoom/offline meeting
-- Chunks are stored in messages table with source_type='meeting'
-- ============================================
CREATE TABLE wa_intel.meetings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    zoom_meeting_id TEXT,                     -- Zoom meeting UUID (null for non-Zoom meetings)
    title TEXT NOT NULL,                      -- Meeting title (e.g., "Rapat Koordinasi Bulanan Feb 2026")
    meeting_date TIMESTAMPTZ NOT NULL,        -- When the meeting took place
    duration_minutes INTEGER,                 -- Total duration
    participants TEXT[],                      -- Array of participant names
    total_chunks INTEGER,                     -- How many 30-min chunks this was split into
    executive_summary TEXT,                   -- AI-generated full meeting summary (synthesized from all chunks)
    raw_transcript TEXT,                      -- Full raw transcript (for search & chat-with-data)
    key_decisions JSONB,                      -- [ { decision, context, owner } ]
    source TEXT DEFAULT 'zoom',               -- 'zoom' / 'google_meet' / 'offline' / 'phone'
    metadata JSONB,                           -- Any additional metadata from Zoom API
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_meetings_date ON wa_intel.meetings(meeting_date DESC);
CREATE INDEX idx_meetings_zoom_id ON wa_intel.meetings(zoom_meeting_id) WHERE zoom_meeting_id IS NOT NULL;

-- ============================================
-- TABLE 5: classified_items
-- Hasil klasifikasi AI dari setiap pesan
-- ============================================
CREATE TABLE wa_intel.classified_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID REFERENCES wa_intel.messages(id) ON DELETE CASCADE,
    classification TEXT NOT NULL,             -- 'task' / 'direction' / 'report' / 'question' / 'coordination' / 'noise'
    confidence REAL,                          -- 0.0 - 1.0 confidence score dari AI
    summary TEXT,                             -- Ringkasan 1-2 kalimat dari AI
    assigned_to TEXT,                         -- Nama orang yang di-assign (extracted by AI)
    assigned_by TEXT,                         -- Nama orang yang memberi tugas
    deadline TEXT,                            -- Deadline (extracted by AI, bisa "besok", "minggu depan", dll)
    deadline_parsed TIMESTAMPTZ,             -- Deadline yang sudah di-parse ke timestamp
    topic TEXT,                               -- Topik utama (e.g., "promo ramadan", "shrinkage", "supplier")
    priority TEXT DEFAULT 'normal',           -- 'urgent' / 'high' / 'normal' / 'low'
    ai_model TEXT,                            -- Model yang digunakan (e.g., "gemini-2.0-flash")
    classified_at TIMESTAMPTZ DEFAULT now(),
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_classified_type ON wa_intel.classified_items(classification);
CREATE INDEX idx_classified_time ON wa_intel.classified_items(classified_at DESC);

-- ============================================
-- TABLE 6: tasks
-- Task yang di-extract dari WA, di-track statusnya
-- ============================================
CREATE TABLE wa_intel.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    classified_item_id UUID REFERENCES wa_intel.classified_items(id),
    source_message_id UUID REFERENCES wa_intel.messages(id),
    title TEXT NOT NULL,                      -- Judul task (dari AI summary)
    description TEXT,                         -- Detail lengkap
    assigned_to TEXT,                         -- Siapa yang harus kerjakan
    assigned_by TEXT,                         -- Siapa yang assign
    group_name TEXT,                          -- Dari grup mana
    status TEXT DEFAULT 'new',                -- 'new' / 'in_progress' / 'done' / 'stuck' / 'cancelled'
    priority TEXT DEFAULT 'normal',           -- 'urgent' / 'high' / 'normal' / 'low'
    deadline TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    completion_message_id UUID REFERENCES wa_intel.messages(id),  -- Pesan konfirmasi selesai
    days_without_response INTEGER DEFAULT 0,  -- Berapa hari tanpa response
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_tasks_status ON wa_intel.tasks(status);
CREATE INDEX idx_tasks_assigned ON wa_intel.tasks(assigned_to);

-- ============================================
-- TABLE 7: directions
-- Arahan dari Hendra — knowledge base
-- ============================================
CREATE TABLE wa_intel.directions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_message_id UUID REFERENCES wa_intel.messages(id),
    title TEXT NOT NULL,                      -- Judul arahan (dari AI summary)
    content TEXT NOT NULL,                    -- Isi lengkap arahan
    topic TEXT,                               -- Topik (e.g., "kebijakan retur", "promo ramadan")
    group_name TEXT,                          -- Dari grup mana
    target_audience TEXT,                     -- Untuk siapa (e.g., "semua store manager", "tim purchasing")
    is_still_valid BOOLEAN DEFAULT true,      -- Apakah arahan masih berlaku
    superseded_by UUID REFERENCES wa_intel.directions(id),  -- Jika di-update oleh arahan baru
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_directions_topic ON wa_intel.directions(topic);
CREATE INDEX idx_directions_valid ON wa_intel.directions(is_still_valid) WHERE is_still_valid = true;

-- ============================================
-- TABLE 8: daily_briefings
-- Log daily briefing yang sudah dikirim
-- ============================================
CREATE TABLE wa_intel.daily_briefings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    briefing_date DATE NOT NULL UNIQUE,
    summary_text TEXT NOT NULL,               -- Isi briefing yang dikirim
    new_tasks_count INTEGER DEFAULT 0,
    overdue_tasks_count INTEGER DEFAULT 0,
    completed_tasks_count INTEGER DEFAULT 0,
    new_directions_count INTEGER DEFAULT 0,
    sent_at TIMESTAMPTZ,
    sent_via TEXT DEFAULT 'whatsapp',         -- 'whatsapp' / 'email' / 'telegram'
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- TABLE 9: embeddings (FASE 2 — RAG Knowledge Base)
-- Vector embeddings untuk semantic search
-- ============================================
-- CATATAN: Enable pgvector extension dulu di Supabase Dashboard
-- CREATE EXTENSION IF NOT EXISTS vector;

-- CREATE TABLE wa_intel.embeddings (
--     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--     source_type TEXT NOT NULL,              -- 'direction' / 'task' / 'message'
--     source_id UUID NOT NULL,                -- ID dari tabel sumber
--     content TEXT NOT NULL,                  -- Teks yang di-embed
--     embedding vector(1536),                 -- OpenAI text-embedding-3-small = 1536 dimensions
--     metadata JSONB,                         -- Extra info: group, sender, topic, date
--     created_at TIMESTAMPTZ DEFAULT now()
-- );
-- CREATE INDEX idx_embeddings_source ON wa_intel.embeddings(source_type, source_id);

-- ============================================
-- VIEWS — untuk kemudahan query
-- ============================================

-- View: Tasks yang overdue (belum done, sudah > 3 hari)
CREATE OR REPLACE VIEW wa_intel.overdue_tasks AS
SELECT
    t.*,
    m.message_text AS original_message,
    EXTRACT(DAY FROM now() - t.created_at) AS days_open
FROM wa_intel.tasks t
LEFT JOIN wa_intel.messages m ON m.id = t.source_message_id
WHERE t.status NOT IN ('done', 'cancelled')
AND t.created_at < now() - INTERVAL '3 days';

-- View: Ringkasan per grup hari ini
CREATE OR REPLACE VIEW wa_intel.today_summary AS
SELECT
    g.name AS group_name,
    COUNT(m.id) AS total_messages,
    COUNT(ci.id) FILTER (WHERE ci.classification = 'task') AS task_count,
    COUNT(ci.id) FILTER (WHERE ci.classification = 'direction') AS direction_count,
    COUNT(ci.id) FILTER (WHERE ci.classification = 'report') AS report_count
FROM wa_intel.groups g
LEFT JOIN wa_intel.messages m ON m.wa_group_id = g.wa_group_id
    AND m.timestamp >= CURRENT_DATE
LEFT JOIN wa_intel.classified_items ci ON ci.message_id = m.id
GROUP BY g.name;

-- ============================================
-- RLS (Row Level Security) — optional
-- Untuk dashboard authentication nanti
-- ============================================
-- ALTER TABLE wa_intel.messages ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE wa_intel.tasks ENABLE ROW LEVEL SECURITY;
-- (implement RLS policies sesuai kebutuhan)
```

---

## 6) MODULE SPECIFICATIONS

### Module 1: WhatsApp Gateway (Baileys Listener)

**Purpose:** Connect ke WhatsApp via nomor cadangan, listen semua pesan dari semua grup, simpan ke Supabase.

**Tech:** Node.js + @whiskeysockets/baileys v7 + @supabase/supabase-js

**Runs on:** PC kantor, managed by PM2 (long-running process 24/7)

**Input:** WhatsApp WebSocket events (messages.upsert)

**Output:** INSERT ke wa_intel.messages

**Key behaviors:**
- Scan QR code satu kali untuk authenticate
- Persist auth state ke filesystem (auth_info/ folder) — supaya tidak perlu scan ulang setiap restart
- Listen event `messages.upsert` — setiap pesan baru dari grup manapun
- Parse: sender JID, sender push name, group JID, message text, timestamp, message type
- **Resolve contact:** lookup sender_jid di wa_intel.contacts → get contact_id, role, location. Jika belum ada, auto-create contact entry dengan JID dan push name (jabatan diisi manual nanti).
- Flag `is_from_hendra` berdasarkan JID Hendra (hardcode atau config)
- INSERT ke Supabase `wa_intel.messages` (termasuk contact_id)
- **Saat startup:** fetch metadata semua grup → upsert wa_intel.groups + wa_intel.group_members
- **Listen event `group-participants.update`** → auto-update group_members ketika ada join/leave
- Auto-reconnect jika connection drop (Baileys handle ini, tapi tambah retry logic)
- JANGAN reply atau kirim pesan apapun (read-only) — kecuali Module 4 (daily briefing, nanti)
- Log errors ke console + optional log file

**Effort:** ~200-400 LOC, 1-2 hari

**GitHub reference (UTAMA):**
- `jlucaso1/whatsapp-mcp-ts` — https://github.com/jlucaso1/whatsapp-mcp-ts
  - Arsitektur Baileys → SQLite → AI query yang paling clean
  - **Cara pakai:** Pelajari cara mereka setup Baileys connection, auth state, dan message handling. Ganti SQLite dengan Supabase client. Buang bagian MCP server — kita tidak butuh itu.
- `nizarfadlan/baileys-api` — https://github.com/nizarfadlan/baileys-api
  - Baileys sebagai REST API dengan Prisma ORM, webhook, multi-session support
  - **Cara pakai:** Referensi untuk session management, reconnect logic, dan webhook pattern. Jika nanti ingin expose REST API untuk Module 3/4 trigger.
- `farinchan/chatery_whatsapp` — https://github.com/farinchan/chatery_whatsapp
  - Express.js + Baileys, paling lengkap: multi-session, WebSocket events, group management, media handling, persistent store
  - **Cara pakai:** Referensi untuk group message handling, media download, dan bulk operations. Arsitekturnya lebih complex — ambil bagian yang perlu saja.

**Baileys core library:**
- `WhiskeySockets/Baileys` — https://github.com/WhiskeySockets/Baileys
  - Docs: https://baileys.wiki
  - NPM: `npm i @whiskeysockets/baileys`
  - TypeScript, WebSocket-based, no browser/Selenium
  - PENTING: Baileys adalah unofficial library. Gunakan dengan bijak. Jangan spam.

---

### Module 2: Database (Supabase Schema)

**Purpose:** Menyimpan semua data — raw messages, classified items, tasks, directions, embeddings.

**Tech:** Supabase PostgreSQL — project HMCS existing, schema `wa_intel`

**Key decisions:**
- Schema `wa_intel` terpisah dari schema `public` (HMCS) — clarity, tidak saling ganggu
- 9 tabel (lihat Section 5 untuk full SQL)
- pgvector extension untuk Fase 2 RAG
- Views untuk query umum (overdue_tasks, today_summary)
- **Cross-schema query ke HMCS (schema `public`) dimungkinkan** — PostgreSQL native support

**Effort:** ~100 LOC (SQL migrations), 3 jam

**Setup steps:**
1. Buka Supabase Dashboard → SQL Editor
2. Jalankan SQL dari Section 5 di atas
3. Verify: semua tabel muncul di schema `wa_intel`
4. (Opsional) Enable pgvector extension untuk Fase 2

---

### Module 3: AI Classifier

**Purpose:** Klasifikasi setiap pesan WA: task / direction / report / question / coordination / noise. Extract entities.

**Tech:** Supabase Edge Function ATAU external Node.js script (cron-based)

**Input:** Pesan baru dari wa_intel.messages (trigger: DB webhook atau cron per 15 menit)

**Output:** INSERT ke wa_intel.classified_items + INSERT ke wa_intel.tasks (jika task) + INSERT ke wa_intel.directions (jika direction dari Hendra)

**AI Prompt Template:**

```
Kamu adalah asisten analisis pesan untuk HollyMart, jaringan supermarket di NTB.

Diberikan pesan WhatsApp dari grup internal perusahaan, klasifikasikan pesan ini.

KONTEKS PENGIRIM:
- Nama: {sender_display_name}
- Jabatan: {sender_role}
- Lokasi: {sender_location}
- Departemen: {sender_department}
- Level leadership: {is_leadership}

KONTEKS GRUP:
- Nama grup: {group_name}
- Deskripsi grup: {group_description}

---
Pengirim: {sender_display_name} ({sender_role}, {sender_location})
Pesan dari Hendra (owner): {is_from_hendra}
Waktu: {timestamp}
Isi pesan:
"{message_text}"
---

Klasifikasikan ke SALAH SATU kategori:
- "task" — ada tugas/pekerjaan yang diberikan ke seseorang
- "direction" — arahan/kebijakan/memo dari leadership (terutama dari Hendra)
- "report" — laporan hasil kerja, update status, angka/data
- "question" — pertanyaan yang perlu dijawab
- "coordination" — koordinasi rutin (jadwal, konfirmasi kehadiran, dll)
- "noise" — chit-chat, sticker, ucapan selamat, tidak ada action item

Jika kategori = "task", extract juga:
- assigned_to: siapa yang harus kerjakan (nama orang)
- assigned_by: siapa yang memberi tugas
- deadline: kapan harus selesai (jika disebutkan)
- priority: "urgent" / "high" / "normal" / "low"

Jika kategori = "direction", extract juga:
- topic: topik utama arahan
- target_audience: untuk siapa arahan ini

Untuk SEMUA kategori:
- summary: ringkasan 1 kalimat dalam Bahasa Indonesia
- confidence: 0.0 - 1.0

PENTING:
- Pesan dari Hendra yang berisi instruksi/kebijakan = "direction"
- Pesan dari Hendra yang menyuruh orang melakukan sesuatu spesifik = "task"
- Jika ragu antara task dan direction, pilih "direction" untuk pesan dari Hendra
- Jika pesan sangat pendek dan ambigu (e.g., "ok", "siap", "👍"), klasifikasikan sebagai "noise" atau "coordination"

Respond dalam JSON format SAJA, tanpa markdown:
{
  "classification": "...",
  "summary": "...",
  "confidence": 0.0,
  "assigned_to": "..." atau null,
  "assigned_by": "..." atau null,
  "deadline": "..." atau null,
  "priority": "..." atau null,
  "topic": "..." atau null,
  "target_audience": "..." atau null
}
```

**Processing modes:**
- **Realtime:** Setiap pesan masuk → langsung classify (best UX, tapi lebih mahal API)
- **Batch:** Setiap 15-30 menit, classify semua pesan yang belum di-classify (lebih hemat)
- **Hybrid:** Pesan dari Hendra = realtime. Pesan lain = batch.

**Task completion detection:**
- Jika ada pesan "sudah", "selesai", "done", "sudah dikerjakan" dari orang yang di-assign → flag task sebagai "done"
- Match berdasarkan: same group + same assigned_to + keyword detection + waktu (within 7 hari dari task creation)
- Ini tidak perlu sempurna — bisa di-review manual di dashboard

**Effort:** ~300-500 LOC, 2-3 hari + iterasi prompt tuning

---

### Module 4: Daily Briefing + Delivery

**Purpose:** Generate daily summary + kirim ke Hendra setiap pagi jam 7 WIB.
**Status:** ✅ Edge function deployed. 🔜 Delivery mechanism & pg_cron scheduling needed.

**Tech:** Supabase Edge Function (generate) + pg_cron (schedule) + Baileys send (deliver)

**Input:** Query wa_intel.classified_items, wa_intel.tasks, wa_intel.directions dari 24 jam terakhir

**Delivery strategy (FINAL DECISION):**
- **Now:** WhatsApp to self — secondary number (listener) sends 1 message/day to Hendra's primary number.
  - Ban risk analysis: 1 message/day to yourself = negligible. WhatsApp has built-in "Message Yourself" feature. This is normal user behavior.
- **Future:** Task notifications to team members will go through **HMCS**, NOT via WhatsApp bot. Reason: HOS §7 says "WA is for coordination, not operations." Sending task reminders via WA bot pushes operations back into WA. HMCS is where the team works daily.
- **Fallback:** WhatsApp via secondary number for urgent escalation only (overdue 3+ days, no response).

**Delivery implementation (for Baileys):**
```typescript
// In the listener process (which already has Baileys connected):
// Add a function to send briefing to Hendra's primary number

async function sendDailyBriefing(sock: WASocket, briefingText: string) {
  const hendraJid = process.env.HENDRA_JID; // primary number
  await sock.sendMessage(hendraJid, { text: briefingText });
}

// Triggered by: Supabase webhook when daily_briefings row is inserted
// OR: node-cron in the listener process at 7am WIB
```

**pg_cron schedule (for edge function):**
```sql
-- Generate briefing at 7am WIB (0am UTC, WIB = UTC+8)
SELECT cron.schedule('daily-briefing', '0 23 * * *',
  $$SELECT net.http_post(
    'https://nnzhdjibilebpjgaqkdu.supabase.co/functions/v1/generate-briefing',
    '{}', 'application/json',
    ARRAY[('Authorization', 'Bearer ' || current_setting('app.settings.service_role_key'))]
  )$$
);
```

**Briefing format:**

```
📊 HollyMart Daily Brief — {tanggal}

🆕 Task Baru (3):
• [Bima-1] Cek harga kompetitor Indomie → @Andi
• [Purchasing] Follow up supplier ikan Ramadan → @Hendra
• [Lombok-2] Atur display promo weekend → @Budi

⚠️ Overdue / No Response (1):
• [Dompu] Kirim laporan shrinkage bulanan → @Dian (5 hari tanpa response)

✅ Completed (2):
• [Bima-1] Update harga minyak goreng → @Rina ✓
• [Lombok-1] Briefing karyawan baru → @Eko ✓

📝 Arahan Baru dari Hendra (1):
• [All Stores] Kebijakan baru soal retur barang expired

💬 Aktivitas Grup:
• Bima-1: 45 pesan (8 penting)
• Purchasing: 23 pesan (5 penting)
• Dompu: 12 pesan (2 penting)
```

**Effort:** ~200-300 LOC, 1 hari

---

### Module 5: Dashboard (Visual)

**Purpose:** Web dashboard untuk Hendra — visual overview, kanban board, search.

**Tech:** Next.js + React + Supabase client + Vercel

**Pages:**

1. **Kanban Board** (/tasks)
   - 4 kolom: New → In Progress → Stuck/Overdue → Done
   - Card: judul task, assigned_to, grup asal, tanggal
   - Drag & drop untuk update status (update wa_intel.tasks)
   - Filter: by group, by assigned_to, by date range

2. **Direction Log** (/directions)
   - List semua arahan dari Hendra, newest first
   - Search by keyword / topic
   - Tag: topic, target_audience, is_still_valid
   - Detail view: isi lengkap + pesan asli dari WA

3. **Group Activity** (/groups)
   - Overview: semua grup, jumlah pesan hari ini, flagged items
   - Click grup → lihat pesan-pesan penting (classified as task/direction/report)
   - Activity chart: message volume per hari per grup

4. **Search** (/search) — Fase 2
   - Full-text search across semua messages
   - Semantic search (RAG) for directions dan important messages
   - "Apa kata Hendra soal X?" → AI jawab berdasarkan context

**Effort:** ~800-1200 LOC, 3-5 hari

---

### Module 6: Chat with Data + Knowledge Base

**Purpose:** Search semua data WA + AI Q&A. "Institutional memory." Onboarding tool untuk karyawan baru.
**Status:** 📋 Planned — Phase A (full-text search) is the priority.

**Implementation approach (pragmatic, layered):**

**Phase A — Full-text search (DO THIS FIRST):**

```sql
-- Add search index to messages table
ALTER TABLE wa_intel.messages ADD COLUMN search_vector tsvector
  GENERATED ALWAYS AS (
    to_tsvector('indonesian', COALESCE(body, '') || ' ' || COALESCE(sender_name, ''))
  ) STORED;

CREATE INDEX idx_messages_search ON wa_intel.messages USING GIN(search_vector);

-- Search function
CREATE OR REPLACE FUNCTION wa_intel.search_messages(query text, limit_count int DEFAULT 20)
RETURNS TABLE(id uuid, body text, sender_name text, group_name text, created_at timestamptz, relevance float)
AS $$
  SELECT m.id, m.body, m.sender_name, g.name as group_name, m.created_at,
         ts_rank(m.search_vector, websearch_to_tsquery('indonesian', query)) as relevance
  FROM wa_intel.messages m
  LEFT JOIN wa_intel.groups g ON m.group_id = g.id
  WHERE m.search_vector @@ websearch_to_tsquery('indonesian', query)
  ORDER BY relevance DESC
  LIMIT limit_count;
$$ LANGUAGE sql;
```

**Phase B — AI-powered Q&A edge function:**

```typescript
// New edge function: chat-with-data
// 1. Take user's natural language question
// 2. Search messages + tasks + directions using full-text search
// 3. Send matching results as context to GPT-4o-mini
// 4. AI answers based ONLY on the data, not general knowledge

const systemPrompt = `You are HollyMart's WhatsApp Intelligence assistant.
Answer questions ONLY based on the WhatsApp data provided below.
If the data doesn't contain the answer, say "Data tidak ditemukan di chat WA."
Always mention the source group and date.
Respond in Bahasa Indonesia.`;

const context = searchResults.map(m =>
  `[${m.group_name}] ${m.sender_name} (${m.created_at}): ${m.body}`
).join('\n');

// Send to AI with retrieved context
const response = await openai.chat.completions.create({
  model: 'gpt-4o-mini',
  messages: [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: `Data WhatsApp:\n${context}\n\nPertanyaan: ${userQuestion}` }
  ]
});
```

**Phase C — Dashboard chat page:**
Add a chat interface to the React dashboard — text input + AI response. This is the "Chat with WA Data" page.

**Phase D — Knowledge base features:**
- Topic tagging for directions (AI adds topics[] during classification)
- Directions search page with filters (by topic, date, store)
- "Onboarding Pack" generator: select a store/role → compile relevant directions from last 6 months → AI generates summary → export as PDF

**Phase E (only if full-text search insufficient) — Vector/semantic search:**
- Supabase pgvector + OpenAI text-embedding-3-small
- Embeddings cost: ~$0.50-1/bulan (very cheap)
- Reference: `supabase-community/chatgpt-your-files` on GitHub

**Effort:** Phase A: 1 day, Phase B: 1 day, Phase C: 1-2 days, Phase D: 3-5 days, Phase E: 2-3 days

---

### Module 7: Meeting Transcript Ingestion (Zoom via n8n)

**Purpose:** Automatically capture, chunk, summarize, and ingest meeting transcripts into the HMSO pipeline.
**Status:** 📋 Planned — next module to build after WhatsApp pipeline is stable.

**Why this matters:**
Rapat Koordinasi Bulanan can run 1-8 hours. Decisions made, tasks assigned, policies announced — all trapped in people's memory or scattered notes. HOS v1 §6: "If it's not written, it didn't happen." Meeting transcripts are the highest-density signal source in the organization.

**Tech:** n8n (self-hosted on same VPS) + Zoom API webhook + OpenRouter (premium AI model)

**End-to-end flow:**

```
Zoom meeting ends
    │
    ▼ (Zoom webhook → n8n)
n8n Workflow:
    │
    ├── Step 1: Receive Zoom webhook payload
    │   Contains: meeting_id, topic, start_time, duration, transcript_url
    │
    ├── Step 2: Fetch full transcript from Zoom API
    │   GET /meetings/{meetingId}/recordings → download transcript (.vtt or .txt)
    │
    ├── Step 3: INSERT meeting record into wa_intel.meetings
    │   { title, date, duration, participants, raw_transcript, source='zoom' }
    │   Returns: meeting_id (UUID)
    │
    ├── Step 4: Chunk transcript into 30-min segments
    │   - Split by timestamp, not character count
    │   - ~2 min overlap between chunks (context continuity)
    │   - If meeting < 30 min → single chunk
    │   - 1hr meeting = 2 chunks, 3hr = 6 chunks, 8hr = 16 chunks
    │
    ├── Step 5: For EACH chunk → AI summarization via OpenRouter
    │   Model: Claude Sonnet or GPT-4o (premium, not mini)
    │   System prompt:
    │   """
    │   You are a meeting intelligence assistant for HollyMart, a supermarket
    │   chain in NTB, Indonesia. Analyze this meeting transcript segment.
    │
    │   Extract and return in Bahasa Indonesia:
    │   1. RINGKASAN: 3-5 bullet point summary of this segment
    │   2. KEPUTUSAN: Decisions made (who decided, what was decided)
    │   3. TASK: Tasks assigned (assignee, description, deadline if mentioned)
    │   4. ARAHAN: Directives or policy announcements (especially from Hendra/leadership)
    │   5. ESKALASI: Issues that need follow-up or were left unresolved
    │   6. PESERTA AKTIF: Who spoke most / contributed to decisions
    │
    │   If Hendra Rusly is speaking and giving instructions, always classify
    │   those as ARAHAN regardless of tone (formal or casual).
    │
    │   Return as structured JSON.
    │   """
    │
    ├── Step 6: INSERT each chunk summary into wa_intel.messages
    │   {
    │     source_type: 'meeting',
    │     message_text: chunk_summary_text,
    │     message_type: 'meeting_chunk',
    │     meeting_id: <from step 3>,
    │     meeting_metadata: {
    │       chunk_index: 1,
    │       total_chunks: 6,
    │       start_time: "00:00:00",
    │       end_time: "00:30:00",
    │       speakers: ["Hendra", "Andi", "Budi"]
    │     },
    │     is_from_hendra: <true if Hendra spoke in this chunk>,
    │     timestamp: <meeting_date + chunk start offset>,
    │     raw_data: { chunk_raw_transcript, ai_response_json }
    │   }
    │
    ├── Step 7: After ALL chunks processed → generate executive summary
    │   Send all chunk summaries to AI → synthesize into 1-page executive summary
    │   UPDATE wa_intel.meetings SET executive_summary = <result>
    │
    └── Step 8: Existing pipeline takes over automatically
          - Classifier picks up meeting chunks (same 15-min cron)
          - Tasks/directions extracted and populated
          - Next daily briefing includes meeting highlights
          - Chat-with-data can search meeting content
          - HMCS receives meeting-sourced tasks
```

**Chunk overlap strategy:**
```
Meeting timeline: |====================================|
                  0m      30m      60m      90m

Chunk 1: |==========...==|
          0m           32m (30 min + 2 min overlap)

Chunk 2:           |==..==========...==|
                   28m              62m (starts 2 min before boundary)

Chunk 3:                      |==..==========...==|
                              58m              92m
```
The 2-minute overlap ensures that if someone says "as I was saying about the supplier issue" at minute 30, the next chunk has the context of what they were saying.

**n8n on VPS setup:**
```bash
# n8n runs on same Biznet NEO Lite VPS as Baileys listener
# Install via Docker (recommended) or npm

# Docker approach:
docker run -d --name n8n \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD=<secure_password> \
  n8nio/n8n

# Or via npm + PM2 (alongside Baileys):
npm install -g n8n
pm2 start n8n --name "n8n"
```

**Required Zoom configuration:**
1. Create Zoom App (Server-to-Server OAuth) at marketplace.zoom.us
2. Enable "Meeting" event subscription → "Meeting ended" webhook
3. Enable Cloud Recording with auto-transcription
4. Webhook URL: `https://<your-vps-ip>:5678/webhook/zoom-meeting-ended`

**Handling meetings WITHOUT Zoom (offline rapatx):**
For offline meetings or phone calls, manual upload path:
- Upload audio file to a simple web form on dashboard
- n8n workflow: receive file → Whisper API (speech-to-text) → same pipeline as Zoom
- Or: paste meeting notes manually into a form → insert as single chunk

**Classifier awareness (update classifier prompt):**
The existing AI classifier must understand meeting chunks differently from WhatsApp messages:
```
When source_type='meeting': This is a 30-minute segment summary from a meeting transcript.
It may contain MULTIPLE tasks, directions, and decisions within a single message.
Extract ALL of them, not just the primary one.
Weight decisions and directions higher — meetings are where policy is made.
```

**Estimated cost per meeting:**
| Meeting Length | Chunks | AI Calls | Est. Cost |
|---|---|---|---|
| 1 hour | 2 | 3 (2 chunks + 1 exec summary) | ~$0.15-0.30 |
| 3 hours | 6 | 7 | ~$0.45-0.90 |
| 8 hours | 16 | 17 | ~$1.20-2.40 |

At 4-8 meetings per month: **~$2-10/month total.**

**Effort:** n8n workflow: 1-2 days. Prompt engineering: 1 day. Testing with real transcripts: 1-2 days. **Total: ~3-5 days.**

---

### Module 8: HMCS Integration

(See Section 14 for full architecture. Summary here for reference.)

**Purpose:** Route HMSO outputs (tasks, briefings, directions) into HMCS where the team already works daily.
**Status:** 📋 Planned — after WhatsApp pipeline stable + meeting ingestion working.

**Implementation:** Start with Pattern A (HMCS reads wa_intel tables directly). Move to Pattern B (API push) when HMCS needs tasks in its own schema.

**Key rule:** Team never needs to know HMSO exists. They just see tasks and briefings appear in HMCS.

---

## 7) BUILD ORDER (Phased Approach)

### Fase 1: Listen & Store ✅ DONE
**Status:** Completed Feb 9, 2026.
- Supabase schema `wa_intel` created (8 tables, 2 views)
- Baileys listener running 24/7 on VPS
- 18,500+ messages captured, 299 groups synced, 11,900+ contacts

### Fase 2: Classify & Brief ✅ PARTIALLY DONE
**Status:** Edge functions deployed. Needs activation & iteration.
- ✅ AI classifier edge function deployed (GPT-4o-mini)
- ✅ Daily briefing edge function deployed
- 🔜 Activate pg_cron scheduling (classify every 15 min, briefing daily 7am)
- 🔜 Fix classification label mismatch in dashboard
- 🔜 Fix messages-to-groups foreign key linking
- 🔜 Batch classify all 18k+ accumulated messages
- 🔜 Iterate classification prompt quality (assignee detection, deadline extraction)

### Fase 3: Dashboard ✅ PARTIALLY DONE
**Status:** React app built via Bolt.new with Supabase Auth.
- ✅ Pages: Overview, Tasks (kanban), Directions, Contacts, Groups, Briefings
- 🔜 Enforce auth on all pages
- 🔜 Fix data display issues

### Fase 4: Delivery (NEXT)
**Goal:** Hendra gets daily brief on WhatsApp without opening the dashboard.
1. Add sending capability to Baileys listener (secondary → primary number)
2. Trigger: after briefing edge function generates → listener sends to Hendra's WA
3. Add overdue task alerts (conditional — only send when items are overdue)

**Deliverable:** Every morning, 1 WhatsApp message with daily intel. Overdue alerts when needed.

### Fase 5: Chat with Data
**Goal:** Ask questions, get AI answers from your WA data.
1. Add full-text search to messages table (tsvector)
2. Build chat-with-data edge function
3. Add chat page to dashboard
4. Topic tagging for directions

**Deliverable:** "Apa yang dibicarakan grup Bima kemarin?" → AI answers from actual data.

### Fase 6: Meeting Transcript Ingestion
**Goal:** Zoom meetings auto-captured, chunked, summarized, and fed into the pipeline.
1. Install n8n on VPS (Docker or PM2)
2. Configure Zoom Server-to-Server OAuth + webhook
3. Build n8n workflow: receive webhook → fetch transcript → chunk → AI summarize → insert
4. Run database migration (add source_type, meeting_metadata to messages + create meetings table)
5. Update classifier prompt to handle meeting chunks (multiple tasks per chunk)
6. Test with real Rapat Koordinasi transcript
7. Build executive summary generation (synthesize all chunks)
8. Optional: manual upload path for offline meetings

**Deliverable:** Meeting ends → transcript automatically chunked, summarized, tasks extracted. Next morning briefing includes meeting highlights. Searchable forever.

### Fase 7: Knowledge Base & Onboarding
**Goal:** Searchable directions, onboarding pack for new staff.
1. Directions search page with filters (topic, date, store)
2. Onboarding pack generator (compile directions → AI summary → PDF)
3. (Optional) Vector search with pgvector if full-text search insufficient

**Deliverable:** New store manager joins → generate onboarding brief from 6 months of directions.

### Fase 8: HMCS Integration (FUTURE)
**Goal:** HMSO feeds structured data into HMCS where the team already works.
1. Check HMCS API capabilities (create tasks? push notifications?)
2. Start with Pattern A: HMCS reads directly from wa_intel schema
3. If needed, Pattern B: edge function pushes to HMCS API
4. Tasks appear in HMCS task system, briefings as dashboard widget

**Deliverable:** Team sees WA-extracted tasks in HMCS. They don't need to know HMSO exists.

---

## 8) CROSS-SCHEMA QUERIES (wa_intel ↔ HMCS)

Schema `wa_intel` dan schema `public` (HMCS) berada di **database PostgreSQL yang sama**. PostgreSQL native support cross-schema query — tidak perlu API call, tidak perlu join antar database. Ini keuntungan utama pakai project Supabase yang sama.

### Contoh Query Cross-Schema

```sql
-- Contoh 1: Enrichment — gabungkan data WA dengan data karyawan HMCS
SELECT
    m.message_text,
    c.display_name,
    c.role,
    e.employee_id,        -- dari tabel HMCS
    e.hire_date            -- dari tabel HMCS
FROM wa_intel.messages m
JOIN wa_intel.contacts c ON c.id = m.contact_id
LEFT JOIN public.employees e ON e.phone_number = c.phone_number;

-- Contoh 2: Cari task dari store manager yang baru direkrut < 3 bulan
SELECT t.*
FROM wa_intel.tasks t
JOIN wa_intel.contacts c ON c.short_name = t.assigned_to
LEFT JOIN public.employees e ON e.phone_number = c.phone_number
WHERE c.role = 'Store Manager'
AND e.hire_date > now() - INTERVAL '3 months';

-- Contoh 3: Nanti jika HMCS punya tabel stores, bisa join lokasi
SELECT
    g.name AS group_name,
    s.store_code,          -- dari HMCS
    s.city,                -- dari HMCS
    COUNT(m.id) AS message_count
FROM wa_intel.groups g
LEFT JOIN public.stores s ON g.name ILIKE '%' || s.store_name || '%'
LEFT JOIN wa_intel.messages m ON m.wa_group_id = g.wa_group_id
GROUP BY g.name, s.store_code, s.city;
```

### Catatan Penting Cross-Schema
- `wa_intel` schema menggunakan `SUPABASE_SERVICE_ROLE_KEY` di server (Baileys listener) — ini bypass RLS dan bisa access semua schema.
- Dashboard (client-side) menggunakan `SUPABASE_ANON_KEY` — perlu set RLS policy yang tepat untuk tabel wa_intel yang diakses.
- Field `hmcs_employee_id` di tabel `wa_intel.contacts` adalah bridge opsional ke data HMCS — populate ini secara manual atau via script matching nomor HP.
- JANGAN buat foreign key constraint cross-schema (wa_intel → public) karena bisa menyulitkan migrasi nanti. Gunakan soft reference (matching by phone_number atau employee_id).

---

## 9) CONTACTS MANAGEMENT

### Kenapa Tabel Contacts Penting?

Tanpa tabel `contacts`, AI classifier hanya tahu "628123456789 mengirim pesan di grup." Dengan contacts, AI tahu "Budi Santoso (Store Manager, Bima-1) mengirim pesan di grup Operasional Bima." Ini meningkatkan akurasi klasifikasi secara drastis.

### Cara Populate Contacts

**Opsi A: Manual (recommended untuk awal)**
- Hendra atau admin HO input data via Supabase Dashboard atau simple admin page
- Data yang dibutuhkan per orang: nomor WA, nama, jabatan, lokasi, departemen
- Estimasi: 50-100 orang = 30 menit kerja manual

**Opsi B: Auto-discover dari Baileys (enrichment)**
- Baileys bisa detect participants di setiap grup
- Saat pertama kali listen, auto-create contact entry dengan JID dan push name
- Data jabatan/lokasi tetap perlu diisi manual (atau dari HMCS)

**Opsi C: Import dari HMCS (jika data karyawan sudah ada)**
```sql
-- Jika HMCS sudah punya tabel employees dengan nomor HP:
INSERT INTO wa_intel.contacts (wa_jid, phone_number, display_name, role, location, hmcs_employee_id)
SELECT
    e.phone_number || '@s.whatsapp.net',
    e.phone_number,
    e.full_name,
    e.position,
    e.store_location,
    e.id
FROM public.employees e
WHERE e.phone_number IS NOT NULL
ON CONFLICT (wa_jid) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    role = EXCLUDED.role,
    location = EXCLUDED.location,
    hmcs_employee_id = EXCLUDED.hmcs_employee_id;
```

### Auto-Sync Group Members dari Baileys

Module 1 (Baileys listener) bisa otomatis populate `group_members` tabel:
- Saat startup: fetch group metadata untuk semua grup → insert/update group_members
- Listen event `group-participants.update` → auto-update ketika ada orang join/leave grup
- Ini memberi visibility: siapa saja di grup mana, kapan join, apakah admin

---

## 10) RISKS & MITIGATIONS

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| WhatsApp ban (listener — read only) | Very Low | Medium | Read-only behavior. Nomor cadangan, bukan operasional. |
| WhatsApp ban (sending briefing — 1 msg/day to self) | Negligible | Low | 1 pesan/hari ke diri sendiri. WA punya fitur "Message Yourself". Normal behavior. |
| WhatsApp ban (future — sending task reminders to team) | Low-Medium | Medium | Low volume (5-20/day), to known contacts, natural language. Mitigate: route through HMCS instead of WA bot. |
| Baileys breaking change (WA update protocol) | Low-Medium | High | Baileys actively maintained, community besar. Monitor GitHub issues. |
| AI classification inaccurate | High (awalnya) | Low | Iterasi prompt. Human review di dashboard. Feedback loop. 80% akurasi sudah membantu. |
| VPS downtime / restart | Low | Medium | PM2 auto-restart. Auth state persisted. Missed messages saat offline = acceptable loss. |
| Supabase free tier limit | Low | Low | 500MB storage cukup. Monitor usage. Upgrade jika perlu ($25/mo). |
| HMCS API changes break integration | Low | Medium | Soft reference (no foreign keys cross-schema). Pattern A (direct read) is resilient. |

### Ban Risk Deep Analysis (WhatsApp Sending)

**Apa yang membuat WhatsApp ban akun:**
- Mengirim pesan massal ke nomor yang tidak dikenal
- Spam ke banyak grup dalam waktu singkat
- Automated behavior yang terlihat seperti marketing bot
- Volume tinggi (ratusan pesan per jam)

**Apa yang TIDAK akan trigger ban:**
- 1 pesan/hari ke nomor sendiri (fitur "Message Yourself" ada di WA resmi)
- 5-20 pesan/hari ke kontak yang sudah disimpan dan saling kenal
- Pesan dengan bahasa natural (bukan template robotik)
- Pesan yang berisi konten relevan (bukan iklan/spam)

**Keputusan:**
- Daily briefing to self: ✅ AMAN — lakukan sekarang
- Task reminders to team (future): ✅ AMAN jika low volume + natural language, tapi LEBIH BAIK via HMCS
- Bulk notifications to all stores: ❌ JANGAN — gunakan HMCS

---

## 11) HENDRA'S IDENTIFIER

Untuk Module 1 (flag `is_from_hendra`) dan Module 3 (special handling direction), konfigurasi JID Hendra:

```
HENDRA_JID=628xxxxxxxxxx@s.whatsapp.net
```

Ganti `628xxxxxxxxxx` dengan nomor WhatsApp Hendra. Ini digunakan untuk:
- Flag pesan dari Hendra di database
- AI classifier: pesan dari Hendra yang berisi instruksi → otomatis classify sebagai "direction"
- Daily briefing: section khusus "Arahan Baru dari Hendra"

---

## 12) FILE STRUCTURE (Suggested)

```
hmso/
├── README.md
├── HMSO_BLUEPRINT.md               ← FILE INI (context document / North Star)
├── package.json
├── .env                            ← All API keys, Supabase, Zoom, OpenRouter
├── .env.example
│
├── listener/                       ← Module 1: Baileys WhatsApp Listener
│   ├── index.ts                    ← Main entry point — Baileys setup, message handler
│   ├── supabase.ts                 ← Supabase client config
│   ├── message-handler.ts          ← Parse & save messages (source_type='whatsapp')
│   ├── send-briefing.ts            ← Send daily brief to Hendra's WA (1x/day)
│   └── auth_info/                  ← Baileys auth state (gitignore this)
│
├── classifier/                     ← Module 3: AI Classifier (all sources)
│   ├── classify.ts                 ← Main classifier logic
│   ├── prompt.ts                   ← AI prompt templates (WA vs meeting variants)
│   ├── task-detector.ts            ← Detect task completion from replies
│   └── batch-process.ts            ← Batch classify unprocessed messages
│
├── briefing/                       ← Module 4: Daily Briefing
│   ├── generate-briefing.ts        ← Query data from ALL sources, format summary
│   ├── send-briefing.ts            ← Trigger Baileys to send via WA
│   └── cron.ts                     ← Cron job setup (or managed by pg_cron)
│
├── meetings/                       ← Module 7: Meeting Transcript Ingestion
│   ├── chunk-transcript.ts         ← Split transcript into 30-min segments
│   ├── summarize-chunk.ts          ← AI summarization via OpenRouter
│   ├── executive-summary.ts        ← Synthesize all chunks into 1-page summary
│   ├── ingest-meeting.ts           ← Full pipeline: fetch → chunk → summarize → insert
│   └── manual-upload.ts            ← Manual upload path for offline meetings
│
├── chat/                           ← Module 6: Chat with Data
│   ├── search.ts                   ← Full-text search across all messages + meetings
│   ├── chat-with-data.ts           ← AI Q&A edge function
│   └── knowledge-base.ts           ← Direction search, onboarding pack generator
│
├── dashboard/                      ← Module 5: React Dashboard
│   ├── app/
│   │   ├── page.tsx                ← Home / overview
│   │   ├── tasks/page.tsx          ← Kanban board
│   │   ├── directions/page.tsx     ← Direction log
│   │   ├── meetings/page.tsx       ← Meeting transcripts & summaries
│   │   ├── groups/page.tsx         ← Group activity
│   │   ├── chat/page.tsx           ← Chat with Data (AI Q&A)
│   │   └── search/page.tsx         ← Full-text search
│   ├── components/
│   ├── lib/
│   │   └── supabase.ts
│   └── package.json
│
├── n8n/                            ← n8n workflow exports (for version control)
│   └── zoom-meeting-ingestion.json ← Exportable n8n workflow definition
│
├── supabase/
│   └── migrations/
│       ├── 001_create_wa_intel_schema.sql
│       ├── 002_add_source_type_and_meetings.sql  ← New: multi-source support
│       └── 003_add_full_text_search.sql           ← New: tsvector indexes
│
└── ecosystem.config.js             ← PM2 config for Baileys listener + n8n
```

---

## 13) ENVIRONMENT VARIABLES

### Supabase Connection (HMCS Project — EXISTING)

**PENTING: Project ini menggunakan database Supabase HMCS yang SUDAH ADA. JANGAN buat project Supabase baru.**

```
Supabase Project URL: https://nnzhdjibilebpjgaqkdu.supabase.co
Supabase Project ID:  nnzhdjibilebpjgaqkdu
```

Semua tabel hmso harus dibuat di schema `wa_intel` — BUKAN di schema `public`.
Schema `public` sudah digunakan oleh HMCS. Jangan sentuh, jangan modify, jangan drop apapun di schema `public`.

### Environment Variables (.env)

```env
# Supabase (HMCS project — EXISTING, JANGAN BUAT BARU)
SUPABASE_URL=https://nnzhdjibilebpjgaqkdu.supabase.co
SUPABASE_ANON_KEY=<get from Supabase Dashboard → Settings → API>
SUPABASE_SERVICE_ROLE_KEY=<get from Supabase Dashboard → Settings → API>

# PENTING: Untuk frontend (Bolt/Vite), gunakan prefix VITE_
VITE_SUPABASE_URL=https://nnzhdjibilebpjgaqkdu.supabase.co
VITE_SUPABASE_ANON_KEY=<same anon key>

# Hendra identifier
HENDRA_JID=628xxxxxxxxxx@s.whatsapp.net

# AI API (pick one — keys disimpan di .env, JANGAN di source code)
OPENAI_API_KEY=<get from platform.openai.com/api-keys>
# GEMINI_API_KEY=<alternative: get from aistudio.google.com>
# ANTHROPIC_API_KEY=<alternative: get from console.anthropic.com>

# Daily briefing delivery
BRIEFING_RECIPIENT_JID=628xxxxxxxxxx@s.whatsapp.net
BRIEFING_TIME=07:00

# Meeting Transcript Ingestion (Zoom + OpenRouter)
ZOOM_ACCOUNT_ID=<from marketplace.zoom.us → Server-to-Server app>
ZOOM_CLIENT_ID=<from marketplace.zoom.us>
ZOOM_CLIENT_SECRET=<from marketplace.zoom.us>
ZOOM_WEBHOOK_SECRET=<webhook verification token>

# OpenRouter (for premium AI — meeting summaries)
OPENROUTER_API_KEY=<from openrouter.ai/keys>
OPENROUTER_MODEL=anthropic/claude-sonnet-4-20250514  # or openai/gpt-4o

# n8n (if self-hosted)
N8N_PORT=5678
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=<secure_password>
```

### SECURITY RULES
- **JANGAN PERNAH** commit `.env` file ke Git
- **JANGAN PERNAH** taruh API keys di source code, markdown, atau chat
- Tambahkan `.env` ke `.gitignore`
- Untuk Bolt: masukkan keys via Bolt's environment/secrets panel, bukan di code

---

## 13b) INSTRUKSI KHUSUS UNTUK BOLT.NEW

Jika project ini dikerjakan menggunakan Bolt.new:

1. **Database:** Gunakan Supabase project EXISTING (URL: `https://nnzhdjibilebpjgaqkdu.supabase.co`). JANGAN buat project Supabase baru. JANGAN jalankan `npx supabase init` atau setup Supabase baru.

2. **Schema:** Semua SQL migrations harus target schema `wa_intel`. Setiap CREATE TABLE harus diawali `wa_intel.` — contoh: `CREATE TABLE wa_intel.messages (...)`. JANGAN gunakan schema `public`.

3. **Existing tables di `public`:** Ada tabel-tabel HMCS di schema `public`. JANGAN query, modify, atau drop tabel-tabel ini. Mereka bukan bagian dari project hmso.

4. **Environment variables:** Set di Bolt's environment panel:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
   - `OPENAI_API_KEY` (atau AI provider lain)

5. **Supabase client config:** Pastikan client mengarah ke project existing:
   ```typescript
   import { createClient } from '@supabase/supabase-js'
   const supabase = createClient(
     import.meta.env.VITE_SUPABASE_URL,
     import.meta.env.VITE_SUPABASE_ANON_KEY
   )
   ```

6. **Querying wa_intel schema dari Supabase JS client:** 
   Supabase JS client default ke schema `public`. Untuk query schema `wa_intel`, ada 2 cara:
   
   **Cara 1 (recommended):** Buat client kedua khusus wa_intel:
   ```typescript
   const waIntel = createClient(
     import.meta.env.VITE_SUPABASE_URL,
     import.meta.env.VITE_SUPABASE_ANON_KEY,
     { db: { schema: 'wa_intel' } }
   )
   // Lalu query normal:
   const { data } = await waIntel.from('messages').select('*')
   // Ini otomatis query wa_intel.messages
   ```
   
   **Cara 2:** Gunakan RPC (SQL function) untuk query complex cross-schema.

7. **Baileys listener:** Bolt.new TIDAK bisa menjalankan Baileys listener (butuh long-running Node.js process). Bolt hanya untuk Dashboard (Module 5). Baileys listener (Module 1) harus di-run terpisah di PC/server.

8. **Fokus Bolt:** Gunakan Bolt untuk build:
   - Dashboard (Module 5): Next.js/Vite + React, kanban board, direction log, group activity
   - Bisa juga: Admin page untuk manage contacts (wa_intel.contacts)
   - Bisa juga: Search interface (Module 6 — Fase 2)

---

## 14) HMCS INTEGRATION ARCHITECTURE (Ready When You Are)

### Context
HMCS (HollyMart Central System) is the primary operational system used daily by the HollyMart team. It has an API. It lives in the same Supabase database as HMSO (schema `public`). HMSO's role is to be the invisible intelligence feeder — data flows one way: HMSO → HMCS.

### What HMSO Produces (outputs HMCS can consume)

| Output | Table/View | Description |
|---|---|---|
| Classified messages | `wa_intel.classified_items` | Every message tagged: task, direction, report, question, coordination, noise |
| Extracted tasks | `wa_intel.tasks` | AI-detected action items with description, source group, assignee, deadline |
| Extracted directions | `wa_intel.directions` | Leadership memos and directives with context |
| Daily briefings | `wa_intel.daily_briefings` | Pre-generated summary in Bahasa Indonesia |
| Contacts | `wa_intel.contacts` | Auto-discovered people with phone numbers |
| Overdue tasks | `wa_intel.overdue_tasks` (view) | Tasks past deadline or stale |

### Integration Patterns (pick based on HMCS capabilities)

**Pattern A — Same Database, Direct Read (START HERE)**

Since both schemas live in the same Supabase instance, HMCS can simply query `wa_intel.*` tables directly. No API needed. Zero effort.

```sql
-- HMCS can read HMSO data directly:
SELECT * FROM wa_intel.tasks WHERE status = 'new' ORDER BY created_at DESC;
SELECT * FROM wa_intel.daily_briefings WHERE DATE(created_at) = CURRENT_DATE;
SELECT * FROM wa_intel.overdue_tasks;
```

Use cases:
- HMCS dashboard widget showing "HMSOligence Summary"
- HMCS task list incorporating WA-extracted tasks
- HMCS notification system reading from wa_intel.overdue_tasks

**Pattern B — API Push (LATER, if HMCS needs tasks in its own schema)**

A Supabase Edge Function watches for new classified items and pushes them to HMCS via its API.

```
New task in wa_intel.tasks
  → database trigger fires
  → calls edge function "sync-to-hmcs"
  → POST to HMCS API: /api/tasks/create
  → HMCS handles notification to assigned user
```

When to use: If HMCS has its own task management system with assignment, status tracking, and notifications that require tasks to live in HMCS's own tables.

**Pattern C — Hybrid (RECOMMENDED LONG-TERM)**

- HMCS reads briefings and directions directly from wa_intel schema (Pattern A)
- Tasks get pushed via API (Pattern B) into HMCS's task system
- Overdue alerts triggered by HMCS's own notification mechanism

### Key Design Rules

1. **One-way flow.** HMSO → HMCS. Never reverse. WA data feeds into operations, not the other way.
2. **No foreign keys cross-schema.** Use soft references (matching by phone_number or employee_id). Keeps schemas independently migratable.
3. **HMSO stays invisible.** Tim tidak perlu tahu HMSO ada. Mereka hanya melihat task dan briefing muncul di HMCS.
4. **Delivery goes through HMCS.** Task notifications to team members should come from HMCS (the system they already use), not from a WhatsApp bot. HOS §7: "WA is for coordination, not operations."
5. **WhatsApp sending reserved for:** Hendra's personal daily brief (1 msg/day) and future urgent escalation only.

### Implementation Checklist (when ready)

- [ ] Check HMCS API: can it create tasks? (POST /api/tasks or equivalent)
- [ ] Check HMCS API: can it push notifications to users?
- [ ] If yes to both → implement Pattern B edge function (sync-to-hmcs)
- [ ] If no → use Pattern A (HMCS reads from wa_intel tables directly)
- [ ] Add HMCS dashboard widget for HMSOligence summary
- [ ] Map wa_intel.contacts to HMCS employees (phone number matching)
- [ ] Test: task created in WA → appears in HMCS → assigned user sees notification

---

## 15) OPENCLAW CONTEXT (Why We Didn't Use It)

### What is OpenClaw?
OpenClaw (formerly Clawdbot, Moltbot) is an open-source self-hosted AI personal assistant created by Peter Steinberger. 68,000+ GitHub stars. It connects messaging apps (WhatsApp, Telegram, Discord) to an AI agent that can execute tasks on your computer (shell commands, file operations, browser control). Uses Baileys for WhatsApp integration (same library as HMSO).

### Why Rejected for HollyMart

| Reason | Detail |
|---|---|
| Security risk | AI has full shell access to host machine. Cybersecurity researchers have raised concerns. |
| Single-user design | Personal assistant, not team tool. No multi-user, no dashboard, no analytics. |
| No classification | Doesn't categorize messages. Just processes what you send it. |
| No visual dashboard | Conversation-only interface. No kanban, no overview, no search page. |
| Overkill | Can control computer, send emails, manage calendar. We just need: read WA → classify → brief. |
| Sends messages via WA | Increases ban risk. HMSO listener is read-only by design. |
| HOS v1 violation | Black box decision making violates "Clarity > Speed". |

### What OpenClaw Users Build (that we should steal ideas from)

Based on research of OpenClaw community (Feb 2026), these are the patterns relevant to HMSO:

1. **Morning briefing via cron** → We have this (Module 4). Add WhatsApp delivery.
2. **Chat with your data (conversational AI)** → Build this (Module 6 Phase B). Edge function + full-text search.
3. **Auto-create tasks from messages** → We have this (Module 3 classifier). Improve prompt quality.
4. **Proactive overdue alerts** → Build this. Edge function + conditional notification.
5. **Knowledge base / second brain** → Build this (Module 6 Phase D). Directions search + onboarding pack.

### Future Consideration
Re-evaluate OpenClaw in 6+ months when security matures. Potential personal use for Hendra (not team operations). Could potentially connect HMSO data to OpenClaw as read-only knowledge source.

---

## 16) NOTES FOR AI CODING ASSISTANT

Ketika kamu (Claude Code / Cursor) membantu coding project ini:

1. **Selalu baca HMSO_BLUEPRINT.md terlebih dahulu** sebelum menulis kode.
2. **Jangan suggest tech stack alternatif** — semua sudah final (lihat Section 2).
3. **Gunakan schema `wa_intel`** untuk semua query Supabase — BUKAN schema `public`. Schema `public` adalah HMCS — jangan sentuh.
4. **Bahasa kode: TypeScript** — konsisten dengan HMCS existing.
5. **Baileys v7** — ada breaking changes dari v6. Refer ke https://baileys.wiki dan https://whiskey.so/migrate-latest.
6. **Supabase client**: gunakan `@supabase/supabase-js` v2. Server-side: service_role_key. Dashboard: anon_key + RLS.
7. **AI API calls**: abstrak ke function terpisah agar mudah swap model. Two-tier strategy: GPT-4o-mini for WA messages, premium model (via OpenRouter) for meeting transcripts.
8. **Error handling**: log errors, jangan crash process. Baileys listener HARUS tetap hidup.
9. **Pesan dari Hendra**: selalu check `is_from_hendra` flag. Ini penting untuk classification dan briefing.
10. **Listener = read-only.** Satu-satunya exception: sending daily briefing to Hendra's primary number (1 msg/day).
11. **Delivery to team → via HMCS, NOT WhatsApp bot.** Jangan build WhatsApp sending ke team members. Task notifications harus muncul di HMCS.
12. **HMCS integration**: wa_intel dan HMCS di database yang sama. HMCS bisa query wa_intel tables langsung. Jangan buat foreign keys cross-schema — gunakan soft reference.
13. **Full-text search BEFORE vector search.** Implement `to_tsvector('indonesian', ...)` dulu. pgvector hanya jika full-text search tidak cukup.
14. **Ban risk awareness**: Sending 1 msg/day to self = safe. Bulk sending to many numbers = JANGAN.
15. **Source-agnostic pipeline.** Selalu check `source_type` column di messages table. Classifier, briefing, search, dan dashboard harus handle semua source types (`'whatsapp'`, `'meeting'`, future sources).
16. **Meeting transcripts**: Chunk summaries masuk ke `wa_intel.messages` (source_type='meeting'). Full meeting record ada di `wa_intel.meetings`. Jangan confuse keduanya.
17. **Meeting AI model**: Gunakan OpenRouter (premium model) untuk meeting summarization, BUKAN GPT-4o-mini. Meeting chunks bisa 3000-5000 kata — butuh model yang kuat.
18. **Classifier prompt harus source-aware**: Meeting chunks bisa mengandung MULTIPLE tasks/directions dalam satu message. Extract semuanya, bukan cuma yang pertama.
