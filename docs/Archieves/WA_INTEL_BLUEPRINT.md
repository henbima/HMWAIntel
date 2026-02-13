# WA_INTEL_BLUEPRINT.md
# HollyMart WhatsApp Intelligence System — Complete Context Document

> **INSTRUKSI UNTUK AI (Claude Code / Cursor):**
> Baca dokumen ini SELURUHNYA sebelum menulis kode apapun.
> Dokumen ini adalah "North Star" untuk project ini.
> Semua keputusan arsitektur sudah final — JANGAN suggest alternatif kecuali diminta.
> Jika ada ambiguitas, rujuk ke bagian "Decisions Already Made" di bawah.

---

## 0) PROJECT IDENTITY

- **Nama project:** HollyMart WA Intelligence (internal codename: `wa-intel`)
- **Owner:** Hendra Rusly — CEO & Lead Developer, HollyMart
- **Tujuan:** Bridge system sementara untuk menangkap, mengklasifikasi, dan menampilkan informasi dari WhatsApp group HollyMart — sampai HMCS/HMLS (sistem utama) siap meng-absorb fungsi ini.
- **Ini BUKAN:** chatbot, auto-reply, marketing tool, atau pengganti HMCS.
- **Ini ADALAH:** read-only intelligence layer yang mengubah chaos WhatsApp menjadi data terstruktur.

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

### 4 Kemampuan yang Dibutuhkan

1. **CAPTURE** — Baca & simpan semua chat dari semua grup WA → database. Read-only. Nomor cadangan.
2. **CLASSIFY** — AI kategorisasi setiap pesan: Task / Arahan / Laporan / Noise. Extract entities: siapa assign ke siapa, deadline, topik.
3. **SURFACE** — Daily briefing setiap pagi + visual dashboard (kanban board, activity overview).
4. **ARCHIVE** — Knowledge base yang searchable. Arahan & memo tersimpan, onboarding orang baru = instant.

---

## 2) DECISIONS ALREADY MADE (FINAL — DO NOT CHANGE)

Berikut keputusan arsitektur yang sudah diambil melalui diskusi mendalam. JANGAN suggest alternatif.

| Keputusan | Pilihan | Alasan |
|---|---|---|
| **WA Gateway** | Baileys (@whiskeysockets/baileys) | Open source, TypeScript, no browser needed, community besar |
| **Database** | Supabase — **project HMCS yang sudah ada**, schema baru `wa_intel` | Menghindari biaya $10/bulan untuk project Supabase baru. Supabase sudah digunakan untuk HMCS. Schema terpisah = clarity tanpa biaya tambahan. |
| **Baileys runner** | PC kantor / laptop yang selalu nyala (PM2) | $0 cost. Baileys butuh long-running Node.js process (24/7 WebSocket). Tidak bisa di serverless (Vercel/Edge Functions timeout). |
| **AI Model** | Gemini 2.0 Flash (free tier) atau Claude/GPT ($0-5/mo) | Free tier cukup untuk volume HollyMart. Bisa swap model tanpa ubah arsitektur. |
| **Dashboard hosting** | Vercel (free tier) + Next.js | $0. Hendra sudah familiar. |
| **RAG / Knowledge Base** | Supabase pgvector di schema `wa_intel` yang sama | Fase 2. Tidak butuh infra terpisah. pgvector extension sudah available di Supabase. |
| **Nomor WhatsApp** | Nomor cadangan / backup — BUKAN nomor operasional utama | Mitigasi risiko ban. Read-mostly. |
| **BUKAN OpenClaw** | Rejected | Security vulnerabilities (CVE Feb 2026), single-user design, overkill untuk kebutuhan ini. Bisa revisit 6+ bulan lagi. |
| **BUKAN Periskope (SaaS)** | Rejected (untuk sekarang) | Hendra memilih build sendiri karena lebih mudah di-customize dan AI-assisted coding sudah cepat. |
| **BUKAN Cloudflare Workers** | Rejected | Menambah complexity tech stack baru. Stick to Supabase yang sudah familiar. |

---

## 3) ARCHITECTURE OVERVIEW

```
┌─────────────────────────────────────────────────────────────────────┐
│                    HollyMart WA Intelligence                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  MODULE 1              MODULE 2              MODULE 3               │
│  ┌──────────┐         ┌──────────┐         ┌──────────┐            │
│  │ Baileys  │ ──────> │ Supabase │ ──────> │ AI       │            │
│  │ Listener │ webhook │ Database │ trigger │ Classify │            │
│  │ (Node.js)│         │ (schema: │         │ (Edge Fn │            │
│  │          │         │ wa_intel)│         │ or cron) │            │
│  └──────────┘         └────┬─────┘         └────┬─────┘            │
│  📱 Nomor cadangan        │                     │                   │
│  🖥️ PC kantor (PM2)       │                     │                   │
│                            │                     │                   │
│                     MODULE 5              MODULE 4                   │
│                     ┌──────────┐         ┌──────────┐              │
│                     │Dashboard │ <────── │ Daily    │              │
│                     │ (Next.js │         │ Briefing │              │
│                     │  Vercel) │         │ (Cron)   │              │
│                     └──────────┘         └──────────┘              │
│                     👁️ Kanban, Search     📬 WA/Email jam 7 pagi   │
│                                                                     │
│                     MODULE 6 (Fase 2)                               │
│                     ┌──────────┐                                    │
│                     │ RAG      │                                    │
│                     │ Knowledge│                                    │
│                     │ Base     │                                    │
│                     │(pgvector)│                                    │
│                     └──────────┘                                    │
│                     🔍 Semantic search                              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
[WhatsApp Groups 15+]
    │
    ▼ (Baileys WebSocket — nomor cadangan sebagai silent member)
[Module 1: Baileys Listener — PC kantor, PM2]
    │
    ▼ (INSERT via Supabase JS client)
[Module 2: Supabase DB — schema wa_intel — tabel messages]
    │
    ▼ (Database webhook / cron trigger)
[Module 3: AI Classifier — Supabase Edge Function atau external script]
    │ Classify: task / direction / report / question / noise
    │ Extract: assigned_to, assigned_by, deadline, topic, group
    │
    ├──▶ [Module 2: tabel classified_items, tasks, directions]
    │
    ├──▶ [Module 4: Daily Briefing — cron setiap jam 7 pagi]
    │         │
    │         ▼ (kirim via Baileys ke WA Hendra, atau email)
    │    [Summary: "3 task baru, 1 overdue, 2 direction executed"]
    │
    ├──▶ [Module 5: Dashboard — Next.js di Vercel]
    │         │
    │         ▼ (Supabase Realtime subscriptions)
    │    [Kanban board, direction search, group activity]
    │
    └──▶ [Module 6: RAG Knowledge Base — pgvector] (Fase 2)
              │
              ▼
         ["Apa arahan Hendra soal kebijakan retur?" → semantic search → AI jawab]
```

---

## 4) TECH STACK

| Layer | Technology | Version | Notes |
|---|---|---|---|
| WA Gateway | `@whiskeysockets/baileys` | v7.x | TypeScript, WebSocket-based |
| Runtime (Baileys) | Node.js | v18+ | Long-running process via PM2 |
| Database | Supabase (PostgreSQL) | Existing HMCS project | Schema: `wa_intel` |
| Vector DB | Supabase pgvector | Extension di project yang sama | Fase 2 |
| AI Classifier | Gemini 2.0 Flash / Claude API / GPT | Swappable | Via Supabase Edge Function atau external |
| Dashboard | Next.js + React | v14+ | Deployed ke Vercel |
| Supabase Client | `@supabase/supabase-js` | v2.x | Untuk Baileys listener & dashboard |
| Process Manager | PM2 | Latest | Keep Baileys alive di PC kantor |
| Hosting (Dashboard) | Vercel | Free tier | Auto-deploy dari GitHub |

### Running Cost

| Item | Cost | Notes |
|---|---|---|
| Supabase | **$0** | Pakai project HMCS existing, schema baru |
| AI API | **$0-5/mo** | Gemini free tier, atau Claude/GPT ~$5/mo |
| Vercel | **$0** | Free tier untuk dashboard |
| VPS / Server | **$0** | PC kantor yang selalu nyala |
| **Total** | **$0-5/mo** | |

---

## 5) DATABASE SCHEMA

Semua tabel berada di schema `wa_intel` dalam Supabase project HMCS yang sudah ada.

```sql
-- ============================================
-- SCHEMA: wa_intel
-- HollyMart WhatsApp Intelligence System
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
-- Raw messages dari WhatsApp — SEMUA pesan masuk ke sini
-- ============================================
CREATE TABLE wa_intel.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wa_message_id TEXT UNIQUE,                -- WhatsApp message ID
    group_id UUID REFERENCES wa_intel.groups(id),
    wa_group_id TEXT NOT NULL,                -- WhatsApp group JID (denormalized for speed)
    sender_jid TEXT NOT NULL,                 -- Sender WhatsApp JID
    sender_name TEXT,                         -- Push name / display name
    contact_id UUID REFERENCES wa_intel.contacts(id),  -- Link ke contacts (resolved by JID lookup)
    message_text TEXT,                        -- Isi pesan (teks)
    message_type TEXT DEFAULT 'text',         -- text / image / video / audio / document / sticker
    media_url TEXT,                           -- URL media jika ada (stored in Supabase Storage)
    is_from_hendra BOOLEAN DEFAULT false,     -- Flag: apakah pesan dari Hendra
    quoted_message_id TEXT,                   -- Jika reply ke pesan lain
    timestamp TIMESTAMPTZ NOT NULL,           -- Waktu pesan dikirim
    raw_data JSONB,                           -- Raw Baileys message object (untuk debugging)
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Index untuk query umum
CREATE INDEX idx_messages_group_time ON wa_intel.messages(wa_group_id, timestamp DESC);
CREATE INDEX idx_messages_sender ON wa_intel.messages(sender_jid);
CREATE INDEX idx_messages_from_hendra ON wa_intel.messages(is_from_hendra) WHERE is_from_hendra = true;
CREATE INDEX idx_messages_timestamp ON wa_intel.messages(timestamp DESC);

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

### Module 4: Daily Briefing

**Purpose:** Kirim summary harian ke Hendra setiap pagi jam 7.

**Tech:** Cron job (node-cron di process Baileys yang sama, ATAU Supabase Edge Function + cron trigger)

**Input:** Query wa_intel.classified_items, wa_intel.tasks, wa_intel.directions dari 24 jam terakhir

**Output:** Formatted summary text, dikirim via Baileys ke WA Hendra (atau email)

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

### Module 6: RAG Knowledge Base (FASE 2)

**Purpose:** Semantic search atas semua arahan dan pesan penting Hendra. "Institutional memory."

**Tech:** Supabase pgvector + OpenAI text-embedding-3-small + AI completion

**How it works:**
1. Setiap direction dan important message → generate embedding (vector 1536 dimensions)
2. Store embedding di wa_intel.embeddings
3. User query (e.g., "kebijakan retur barang") → generate query embedding → similarity search → top 5 results
4. Top 5 results + user question → AI generates answer with context

**GitHub reference:**
- `supabase-community/chatgpt-your-files` — https://github.com/supabase-community/chatgpt-your-files
  - Production-ready RAG: Supabase + pgvector + Next.js + OpenAI
  - **Cara pakai:** Fork ini sebagai basis. Ganti "file upload" dengan "WA directions & messages." Schema embedding sudah ada — adapt ke wa_intel schema.

**Embeddings cost:**
- OpenAI text-embedding-3-small: $0.02 per 1 juta token
- Estimasi HollyMart: ~$0.50-1/bulan (sangat murah)
- "Embeddings" = proses mengubah teks menjadi angka (vector) agar AI bisa memahami kesamaan makna antara query dan dokumen

**Effort:** ~300-400 LOC, 2-3 hari

---

## 7) BUILD ORDER (Phased Approach)

### Fase 1: Listen & Store (2-3 hari)
**Goal:** Semua chat dari semua grup tersimpan di database.

1. Setup Supabase schema `wa_intel` (Module 2)
2. Build Baileys listener (Module 1)
3. Connect nomor cadangan, scan QR
4. Test: pesan masuk dari grup → muncul di Supabase table
5. Run via PM2 di PC kantor

**Deliverable:** Semua WA chat tersimpan dan queryable via SQL. Fase 1 saja sudah bernilai — HOS v1: "If it's not written, it didn't happen."

### Fase 2: Classify & Brief (3-4 hari)
**Goal:** AI classify pesan + Hendra dapat morning recap.

1. Build AI classifier (Module 3) — mulai batch mode (per 15 menit)
2. Test & iterate prompt (ini butuh beberapa kali percobaan)
3. Build daily briefing (Module 4) — cron job jam 7 pagi
4. Test: briefing terkirim ke WA Hendra

**Deliverable:** Hendra buka 1 pesan briefing setiap pagi, bukan 500+ chat.

### Fase 3: See & Search (5-7 hari)
**Goal:** Dashboard visual + kanban + search.

1. Build Next.js dashboard (Module 5)
2. Deploy ke Vercel
3. Connect ke Supabase realtime
4. Build kanban board, direction log, group activity
5. (Optional) RAG knowledge base (Module 6)

**Deliverable:** Full visual dashboard, kanban task tracking, searchable direction log.

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
| WhatsApp ban nomor cadangan | Medium | Medium | Gunakan nomor dedicated. Read-only behavior. Jangan spam. Jangan kirim bulk messages. |
| Baileys breaking change (WA update protocol) | Low-Medium | High | Baileys actively maintained, community besar. Monitor GitHub issues. |
| AI classification inaccurate | High (awalnya) | Low | Iterasi prompt. Human review di dashboard. Feedback loop. Tidak perlu 100% akurat — 80% sudah sangat membantu. |
| PC kantor mati / restart | Medium | Medium | PM2 auto-restart. Auth state persisted ke disk. Pesan yang missed saat offline = acceptable loss. |
| Supabase free tier limit | Low | Low | 500MB storage sangat cukup. Monitor usage. Upgrade jika perlu ($25/mo). |

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
wa-intel/
├── README.md
├── WA_INTEL_BLUEPRINT.md          ← FILE INI (context document)
├── package.json
├── .env                            ← Supabase URL, Supabase Key, Hendra JID, AI API key
├── .env.example
│
├── listener/                       ← Module 1: Baileys Listener
│   ├── index.ts                    ← Main entry point — Baileys setup, message handler
│   ├── supabase.ts                 ← Supabase client config
│   ├── message-handler.ts          ← Parse & save messages
│   └── auth_info/                  ← Baileys auth state (gitignore this)
│
├── classifier/                     ← Module 3: AI Classifier
│   ├── classify.ts                 ← Main classifier logic
│   ├── prompt.ts                   ← AI prompt template
│   ├── task-detector.ts            ← Detect task completion from replies
│   └── batch-process.ts            ← Batch classify unprocessed messages
│
├── briefing/                       ← Module 4: Daily Briefing
│   ├── generate-briefing.ts        ← Query data, format summary
│   ├── send-briefing.ts            ← Send via Baileys/email
│   └── cron.ts                     ← Cron job setup (node-cron)
│
├── dashboard/                      ← Module 5: Next.js Dashboard (or separate repo)
│   ├── app/
│   │   ├── page.tsx                ← Home / overview
│   │   ├── tasks/page.tsx          ← Kanban board
│   │   ├── directions/page.tsx     ← Direction log
│   │   ├── groups/page.tsx         ← Group activity
│   │   └── search/page.tsx         ← Search (Fase 2)
│   ├── components/
│   ├── lib/
│   │   └── supabase.ts
│   ├── next.config.js
│   └── package.json
│
├── supabase/
│   └── migrations/
│       └── 001_create_wa_intel_schema.sql  ← Full schema from Section 5
│
└── ecosystem.config.js             ← PM2 config for Baileys listener
```

---

## 13) ENVIRONMENT VARIABLES

### Supabase Connection (HMCS Project — EXISTING)

**PENTING: Project ini menggunakan database Supabase HMCS yang SUDAH ADA. JANGAN buat project Supabase baru.**

```
Supabase Project URL: https://nnzhdjibilebpjgaqkdu.supabase.co
Supabase Project ID:  nnzhdjibilebpjgaqkdu
```

Semua tabel wa-intel harus dibuat di schema `wa_intel` — BUKAN di schema `public`.
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

3. **Existing tables di `public`:** Ada tabel-tabel HMCS di schema `public`. JANGAN query, modify, atau drop tabel-tabel ini. Mereka bukan bagian dari project wa-intel.

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

## 14) NOTES FOR AI CODING ASSISTANT

Ketika kamu (Claude Code / Cursor) membantu coding project ini:

1. **Selalu baca WA_INTEL_BLUEPRINT.md terlebih dahulu** sebelum menulis kode.
2. **Jangan suggest tech stack alternatif** — semua sudah final (lihat Section 2).
3. **Gunakan schema `wa_intel`** untuk semua query Supabase — BUKAN schema `public`.
4. **Bahasa kode: TypeScript** — konsisten dengan HMCS existing.
5. **Baileys v7** — ada breaking changes dari v6. Refer ke https://baileys.wiki dan https://whiskey.so/migrate-latest.
6. **Supabase client**: gunakan `@supabase/supabase-js` v2. Untuk server-side (listener), gunakan service_role_key. Untuk dashboard, gunakan anon_key + RLS.
7. **AI API calls**: abstrak ke function terpisah agar mudah swap model (Gemini ↔ Claude ↔ GPT).
8. **Error handling**: log errors, jangan crash process. Baileys listener HARUS tetap hidup.
9. **Pesan dari Hendra**: selalu check `is_from_hendra` flag. Ini penting untuk classification dan briefing.
10. **Fase 2 (RAG/embeddings)**: JANGAN implement sekarang kecuali diminta. Fokus Fase 1 dulu.
