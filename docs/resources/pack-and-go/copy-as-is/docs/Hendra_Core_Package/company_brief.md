# HollyMart Company Brief
# Purpose: Provide AI assistants and developers with deep, reusable context about HollyMart for consistent, operationally-aware outputs.

## 0) Source of Truth
This context is based on:
- Internal working knowledge from ongoing HollyMart discussions (ops, SOP, compliance, systems).
- Company Brief – HollyMart (2025). :contentReference[oaicite:1]{index=1}

If any instruction conflicts, this file wins.

---

## 1) Company Snapshot
**Company:** HollyMart  
**Industry:** Retail grocery & convenience store chain  
**Operating regions:** Bima, Dompu, Lombok (Nusa Tenggara Barat) :contentReference[oaicite:2]{index=2}  
**Store format:** small to medium outlets; convenience + daily/weekly needs; affordable pricing + friendly service :contentReference[oaicite:3]{index=3}  
**Scale (2025):** ~230 active employees across outlets, DC, and Head Office (HO) :contentReference[oaicite:4]{index=4}  
**Operating model:** Multi-outlet stores + HO + Distribution Center (DC)

### Retail reality (important for SOP design)
- Outlets are generally small → staff roles are broad and multi-task end-to-end (receiving, shelves, expiry checks, customer service, cashier).
- SOP must be executable under busy conditions with limited staff.

---

## 2) Vision, Mission, Values (Write SOPs aligned to these)
### Vision (2025)
**“Menjadi Supermarket Keluarga Terbaik, Ramah, dan Nyaman di Nusa Tenggara Barat.”** :contentReference[oaicite:5]{index=5}

### Mission (summarized for SOP alignment)
- Provide wholehearted service with complete, quality products at fair prices :contentReference[oaicite:6]{index=6}
- Build mutually beneficial supplier partnerships using accurate data, on-time payment, measurable performance :contentReference[oaicite:7]{index=7}
- Develop strong-character employees via continuous training :contentReference[oaicite:8]{index=8}
- Build a healthy growing company that contributes to stakeholders (community, government, suppliers, employees, shareholders) :contentReference[oaicite:9]{index=9}

### Core Values (Nilai Inti)
- Integritas (disiplin, tanggung jawab, jujur) :contentReference[oaicite:10]{index=10}
- Kerjasama (komunikasi, koordinasi, saling mendukung) :contentReference[oaicite:11]{index=11}
- Berpikir positif & terbuka :contentReference[oaicite:12]{index=12}
- Belajar & berinovasi :contentReference[oaicite:13]{index=13}
- Kerja keras (antusias, efektif, efisien, fokus) :contentReference[oaicite:14]{index=14}
- Pelayanan (produk & service terbaik) :contentReference[oaicite:15]{index=15}

**Operational implication:** Every system, SOP, or tool should help deliver: service quality, data accuracy, efficiency, training enablement, and consistent compliance.

---

## 3) Organization & Roles (How HollyMart runs)
### High-level structure
Direktur → Manager Operasional / Sales Area Manager → Store Manager → Kepala Departemen Store → Staff Store :contentReference[oaicite:16]{index=16}

### Supporting divisions (common)
Merchandising, Finance & Accounting, HR, GA, MarCom, Analyst, and Audit (independent function). :contentReference[oaicite:17]{index=17}

### Store roles (common)
- **Store Crew / SPG/SPB:** receiving incoming goods, shelf stocking, expiry checks, customer service, basic merchandising, sometimes cashier
- **Cashier:** transactions, cash discipline, closing, basic customer service
- **Store Manager (SM):** execution owner; staffing, daily ops, compliance, reporting, escalations
- **Kepala Departemen Store:** executes and enforces standards within a department/section

### DC roles (common)
- inbound receiving, putaway, picking, staging, dispatch, inventory accuracy

### Governance roles (for SOP lifecycle)
- **Dept Head** = SOP owner/publisher for their domain
- **Audit/Compliance (independent)** = verifies adherence + evidence quality, prevents “paper compliance”

---

## 4) Divisions & Functions (What SOPs commonly cover)
- **Retail Operations:** daily sales, customer service, SOP compliance :contentReference[oaicite:18]{index=18}
- **HR:** recruitment, pre-screening, training via LMS, payroll & BPJS :contentReference[oaicite:19]{index=19}
- **Purchasing & Merchandising:** supplier, SKU assortment, planogram, promo :contentReference[oaicite:20]{index=20}
- **Marketing & Communications:** campaigns, promo briefs, digital media, POP design :contentReference[oaicite:21]{index=21}
- **Finance & Accounting:** cash flow, supplier payment, audit & compliance :contentReference[oaicite:22]{index=22}
- **Area Management & Leadership:** multi-outlet supervision, leadership training :contentReference[oaicite:23]{index=23}
- **IT & Systems:** HMCS/HMLS as the digital backbone :contentReference[oaicite:24]{index=24}

---

## 5) Systems & Tools (What SOP should assume exists)
### Execution + audit (preferred)
- **HMCS (Management & Compliance System):** task/incident/audit engine (one-time + recurring tasks). Used for assignment, approvals, evidence capture, audit trail.

### Intelligence
- **HMWAIntel (WhatsApp Intelligence):** monitors WhatsApp group conversations, classifies messages via AI, surfaces tasks/directions/briefings for leadership.

### Training enablement
- **HMLS (Learning System):** onboarding + SOP training + role-based learning paths.

### Legacy data
- **AFFARI (MS SQL Server):** POS/back-end DB; limited documentation.

### Communication rule-of-thumb (Hard rule)
- **WhatsApp:** coordination/alerts only (short-lived), not the system of record. HMWAIntel monitors WA for intelligence extraction.
- **HMCS:** system of record for tasks, approvals, evidence, audits.
- **HMLS:** system of record for training completion.

---

## 6) Current Challenges (Design SOPs to solve these)
### Business/ops challenges
- SOP consistency & compliance not evenly distributed across outlets :contentReference[oaicite:25]{index=25}
- Some new branches (example HM08) have low sales despite high traffic :contentReference[oaicite:26]{index=26}
- Distribution/logistics risks: expired goods, OOS, shrinkage :contentReference[oaicite:27]{index=27}
- Expansion must be data-based (ROI/feasibility) :contentReference[oaicite:28]{index=28}

### People challenges (SDM) – common failure modes to address in SOP
1) High turnover in frontliners (SPG/SPB, cashier, store staff) → repetitive recruitment/training, inconsistent service :contentReference[oaicite:29]{index=29}  
2) Discipline & SOP compliance uneven → “paper compliance” vs real execution → repeatable errors (expired, shrinkage, empty display) :contentReference[oaicite:30]{index=30}  
3) Supervision quality gap (SM/leader varies) → inconsistent standards across stores :contentReference[oaicite:31]{index=31}  
4) Training is still ad-hoc; HMLS still in development → skill gaps across staff :contentReference[oaicite:32]{index=32}  
5) Limited middle-management talent (supervisor/area manager/buyer/merchandiser) who truly understand modern retail systems :contentReference[oaicite:33]{index=33}  
6) Culture gap: HO system-driven vs store reactive/pragmatic → “zero repeatable errors” not internalized everywhere :contentReference[oaicite:34]{index=34}  

**Operational implication:** SOPs and systems must be short, evidence-driven, and designed for enforcement and training—because turnover + skill gap is real.

---

## 7) Manager-Level Expectations (SOP must enable these outcomes)
Managers are expected to: :contentReference[oaicite:35]{index=35}
- Lead division to achieve Vision/Mission
- Live the company values
- Be a **builder of system**, not merely a controller
- Guarantee SOP & compliance consistency across outlets
- Reduce repeatable errors via system improvement + training
- Improve efficiency and control shrinkage/expired/loss/damage/costs (example shrinkage target mentioned: <1%) :contentReference[oaicite:36]{index=36}
- Support expansion with feasibility study & ROI analysis
- Be role model & coach for supervisors and frontline staff

---

## 8) SOP Output Expectations (HollyMart Standard)
### Tone & format
- Retail-floor language, clear and direct.
- Designed for “fresh graduate / unemployed youth” capability in frontline SOPs.
- Always role-based; never person-based.

### Evidence & auditability (must be built-in)
Every SOP must specify:
- **Evidence required** (photo, checklist, HMCS log, report, count sheet, cashier closing)
- **Storage location** (HMCS attachment / AFFARI report name / physical binder if unavoidable)
- **Verifier** (SM / Audit / Dept Head)
- **Frequency** (
