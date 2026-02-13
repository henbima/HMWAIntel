---
config:
  layout: dagre
  theme: base
---
flowchart TB
    %% ============================================================
    %% STRUKTUR ORGANISASI HOLLYMART - v5.1 (Naming Standardized)
    %% 227 Karyawan | 7 Toko + DC + HO | Bima & Sumbawa, NTB
    %% ============================================================
    %% PENDEKATAN:
    %%   - Posisi KOSONG ditampilkan (kotak merah)
    %%   - Kabag (G6) = posisi asli Iga/Devi/Deden/Rusdin
    %%   - Plt = anotasi di bawah Kabag
    %%   - Semua G3 di Merchandising = "Buyer [spesialisasi]"
    %%   - Tim Sayur → Staf Pembelian Fresh
    %% ============================================================

    DIR["<b>DIREKTUR</b><br/>Hendra<br/><i>G8</i>"]

    %% ============================================================
    %% MANAJER DIVISI — 2 TERISI, 5 KOSONG
    %% ============================================================
    DIR --> M_MERCH["<b>Manajer Divisi</b><br/>Merchandising<br/><i>G7</i> Abdul Faruk"]
    DIR --> M_FIN["<b>Manajer Divisi</b><br/>Keuangan & Akuntansi<br/><i>G7</i> Olivia"]
    DIR --> M_OPS["<b>Manajer Divisi</b><br/>Operasional Toko<br/><i>G7</i> ❌ KOSONG"]
    DIR --> M_HRGA["<b>Manajer Divisi</b><br/>HRD, GA & IT<br/><i>G7</i> ❌ KOSONG"]
    DIR --> M_BSA["<b>Manajer Divisi</b><br/>Business Systems<br/>& Analytics<br/><i>G7</i> ❌ KOSONG"]
    DIR --> M_MAR["<b>Manajer Divisi</b><br/>Marketing & Komm.<br/><i>G7</i> ❌ KOSONG"]
    DIR -.-> M_AUDIT["<b>Manajer Divisi</b><br/>Audit Internal & QA<br/><i>G7</i> ❌ KOSONG"]

    %% ============================================================
    %% DIVISI OPERASIONAL — Plt Area: Mursinatun
    %% ============================================================
    M_OPS --> AREA["<b>Koordinator Area</b><br/><i>Plt: Mursinatun</i><br/>(merangkap Katoko HM01)"]

    AREA --> KT1["<b>Kepala Toko HM01</b><br/><i>G6</i> Mursinatun<br/>👤 33 org ⭐"]
    AREA --> KT2["<b>Kepala Toko HM02</b><br/><i>G6</i> M. Seprizal<br/>👤 25 org"]
    AREA --> KT34["<b>Kepala Toko HM0304</b><br/><i>G6</i> Hairunnisah<br/>👤 24 org"]
    AREA --> KT5["<b>Kepala Toko HM05</b><br/><i>G6</i> Junaidin<br/>👤 23 org"]
    AREA --> KT6["<b>Kepala Toko HM06</b><br/><i>G6</i> Julfah<br/>👤 22 org"]
    AREA --> KT7["<b>Kepala Toko HM07</b><br/>Sumbawa<br/><i>G6</i> Khairunnisah<br/>👤 26 org"]
    AREA --> KT8["<b>Kepala Toko HM08</b><br/>Sumbawa<br/><i>G6</i> Irman Ardianto<br/>👤 12 org"]

    %% HM01 Detail
    KT1 --> WK1A["Wakil Katoko <i>G5</i><br/>Man Marzuki"]
    KT1 --> WK1B["Wakil Katoko <i>G5</i><br/>Anang Ma'ruf"]
    KT1 --> KK1["Koord. Kasir <i>G5</i><br/>Yuyun Sukarwati"]
    KT1 --> KG1["Koord. Gudang Toko <i>G5</i>"]

    KT2 --> KT2S[/"Wakil Katoko: Tiona<br/>Koord Kasir: Fani"/]
    KT34 --> KT34S[/"Wakil Katoko: Inang M.<br/>Koord Kasir: ❌ KOSONG"/]
    KT5 --> KT5S[/"Wakil Katoko: Santi<br/>Koord Kasir: Mutmainah"/]
    KT6 --> KT6S[/"Wakil Katoko: Yerin + Dewi A.<br/>Koord Kasir: Ratu Fatimah"/]
    KT7 --> KT7S[/"Wakil Katoko: Munawir"/]
    KT8 --> KT8S[/"Toko terkecil"/]

    %% ============================================================
    %% DIVISI HRD, GA & IT — Plt: Iga
    %% ============================================================
    M_HRGA --> KB_HRGA["<b>Kabag HRD & GA</b><br/><i>G6</i> Iga Apriani<br/>📌 <i>Plt Manajer Divisi</i>"]

    KB_HRGA --> S_HRD["Staf HRD <i>G2</i><br/>Azizul Rahman"]
    KB_HRGA --> KB_ENG["<b>Kabag Engineering/GA</b><br/><i>G6</i> Fuad Fauzi"]
    KB_ENG --> S_TECH["Teknisi <i>G2</i><br/>Ardiansyah"]

    %% ============================================================
    %% DIVISI BSA — Plt: Devi
    %% ============================================================
    M_BSA --> KB_BSA["<b>Kabag Business<br/>Systems & Analytics</b><br/><i>G6</i> Devi Lastri<br/>📌 <i>Plt Manajer Divisi</i>"]

    KB_BSA --> S_IT1["Staf IT & Dev <i>G3</i><br/>Nurlaili Sukmawati"]
    KB_BSA --> S_IT2["Staf IT & Dev <i>G3</i><br/>Nur Rafli"]

    %% ============================================================
    %% DIVISI MARKETING — Plt: Deden
    %% ============================================================
    M_MAR --> KB_MAR["<b>Kabag Marketing<br/>& Komunikasi</b><br/><i>G6</i> Dede Wahyudin<br/>📌 <i>Plt Manajer Divisi</i>"]

    KB_MAR --> S_MKT1["Staf Marcom <i>G3</i><br/>Novia Rahma"]
    KB_MAR --> S_MKT2["Jr. Staff <i>G2</i><br/>Khalid Afif"]

    %% ============================================================
    %% DIVISI AUDIT — Plt: Rusdin
    %% ============================================================
    M_AUDIT --> KB_AUD["<b>Kabag Audit<br/>Internal & QA</b><br/><i>G6</i> Rusdin<br/>📌 <i>Plt Manajer Divisi</i>"]

    KB_AUD --> S_AUD1["Auditor <i>G3</i><br/>Fauziah"]
    KB_AUD --> S_AUD2["Auditor <i>G3</i><br/>Rut Anike Rihi"]
    KB_AUD --> S_AUD3["Auditor <i>G3</i><br/>Patrick Orranil"]

    %% ============================================================
    %% DIVISI MERCHANDISING — NAMING STANDAR: Semua G3 = Buyer
    %% ============================================================
    M_MERCH --> KB_FF["<b>Kabag Buying</b><br/>Food & Fresh<br/><i>G6</i> M. Sahdan"]
    M_MERCH --> KB_NF["<b>Kabag Buying</b><br/>Non-Food<br/><i>G6</i> Safitri"]
    M_MERCH --> KB_GM["<b>Kabag Buying</b><br/>GM & Fashion<br/><i>G6</i> Neni Fitriani"]
    M_MERCH --> KB_DC["<b>Kabag</b><br/>Distribution Center<br/><i>G6</i> Heri Susanto<br/>👤 22 org"]

    %% Food & Fresh — SEMUA G3 = Buyer
    KB_FF --> B_FR1["Buyer Fresh <i>G3</i><br/>Iba Nursyahbaniyah"]
    KB_FF --> B_FR2["Buyer Fresh <i>G3</i><br/>Reni Anggriani"]
    KB_FF --> B_FD1["Buyer Food <i>G3</i><br/>Reni Aprilianingsih"]
    B_FR2 --> SPF["Staf Pembelian Fresh<br/>2 org <i>G1</i><br/>Feby Inda E., Elena Puspita"]

    %% Non-Food — SEMUA G3 = Buyer
    KB_NF --> B_NF1["Buyer Non-Food <i>G3</i><br/>Fitriani"]
    KB_NF --> B_NF2["Buyer Non-Food <i>G3</i><br/>Lisdan Aryanti"]
    KB_NF --> B_NF3["Buyer Non-Food <i>G3</i><br/>Kamarulah"]

    %% GM & Fashion — SEMUA G3 = Buyer
    KB_GM --> B_GM1["Buyer GM <i>G3</i><br/>Kiki Syahnakri"]
    KB_GM --> B_GM2["Buyer Fashion <i>G3</i><br/>Nila Susanti"]

    %% DC (22 org)
    KB_DC --> KO_GDG["Koord. Gudang DC <i>G5</i><br/>Adhar, Burhan, Rangga"]
    KB_DC --> KO_ADM["Koord. Admin DC <i>G5</i><br/>Fitrah"]
    KO_ADM --> ADM_DC["Admin DC 4 org <i>G2</i><br/>Rahmawati, Meltida,<br/>Ade, Ayu Anggelina"]
    KO_GDG --> HLP_DC["Helper Gudang<br/>~12 org <i>G1</i>"]
    KB_DC --> DRV["Driver & Sr. Helper<br/><i>G2</i>"]

    %% ============================================================
    %% DIVISI KEUANGAN & AKUNTANSI
    %% ============================================================
    M_FIN --> KB_ACC["<b>Kabag Akuntansi</b><br/><i>G6</i> Nurwalidatul I."]
    M_FIN --> KB_KU["<b>Kabag Keuangan</b><br/><i>G6</i> Rosdiana"]

    KB_ACC --> S_ACC["Staf Akuntansi 4 org <i>G3</i><br/>Cicilia, Ayu Retno,<br/>Alfi, Abdila"]
    KB_KU --> S_KU["Staf Keuangan 2 org <i>G3</i><br/>Murniati, Nur Afniarni"]

    %% ============================================================
    %% STYLING
    %% ============================================================
    classDef director fill:#1a365d,stroke:#1a365d,color:#fff
    classDef mgr fill:#2b6cb0,stroke:#2b6cb0,color:#fff
    classDef vacancy fill:#e53e3e,stroke:#c53030,color:#fff
    classDef kabag fill:#bee3f8,stroke:#63b3ed,color:#1a365d
    classDef kabagPlt fill:#c4b5fd,stroke:#7c3aed,color:#1a1a2e
    classDef area fill:#f59e0b,stroke:#d97706,color:#1a1a2e
    classDef coord fill:#e2e8f0,stroke:#a0aec0,color:#2d3748
    classDef buyer fill:#e9d8fd,stroke:#9f7aea,color:#44337a
    classDef admin fill:#fefcbf,stroke:#d69e2e,color:#744210
    classDef helper fill:#fed7d7,stroke:#fc8181,color:#742a2a
    classDef store fill:#48bb78,stroke:#276749,color:#fff
    classDef coll fill:#f0fff4,stroke:#9ae6b4,color:#276749

    class DIR director
    class M_MERCH,M_FIN mgr
    class M_OPS,M_HRGA,M_BSA,M_MAR,M_AUDIT vacancy
    class AREA area
    class KB_FF,KB_NF,KB_GM,KB_ACC,KB_KU,KB_ENG kabag
    class KB_DC kabag
    class KB_HRGA,KB_BSA,KB_MAR,KB_AUD kabagPlt
    class KO_GDG,KO_ADM,WK1A,WK1B,KK1,KG1 coord
    class B_FR1,B_FR2,B_FD1,B_NF1,B_NF2,B_NF3,B_GM1,B_GM2,S_ACC,S_KU,S_AUD1,S_AUD2,S_AUD3,S_MKT1,S_IT1,S_IT2 buyer
    class ADM_DC,DRV,S_HRD,S_TECH,S_MKT2 admin
    class HLP_DC,SPF helper
    class KT1,KT2,KT34,KT5,KT6,KT7,KT8 store
    class KT2S,KT34S,KT5S,KT6S,KT7S,KT8S coll