# **Arsitektur Logika Sistem Informasi Terdokumentasi: Pedoman Teknis Pengembangan Software Manajemen Mutu Berbasis AI sesuai Standar ISO 9001:2015**

Laporan ini berfungsi sebagai spesifikasi logika bagi pengembang sistem HMCS untuk mengotomatisasi pembuatan dokumentasi Sistem Manajemen Mutu (SMM). Fokus utama adalah memastikan setiap dokumen memenuhi kriteria audit internasional (Klausul 7.5 ISO 9001:2015) dengan menghilangkan ambiguitas operasional.1

## **1. Hierarki Dokumentasi: Basis Logika Klasifikasi (SOP vs. WI)**

AI harus menentukan jenis dokumen berdasarkan cakupan tanggung jawab dan kompleksitas tugas.3

|Kategori|Cakupan (Scope)|Format Visual \& Aturan UI|Penanggung Jawab|
|-|-|-|-|
|**SOP**|Cross-functional (Antar Departemen).|**Format 3-Kolom Wajib**: Memetakan interaksi "Siapa melakukan Apa". Menggunakan *Swimlanes* jika perlu.|Manajer / Process Owner. 3|
|**Work Instruction (WI)**|Task-specific (Satu Jabatan/Workstation).|**Format Fleksibel**: Tidak wajib 3-kolom. Lebih efektif menggunakan checklist, foto dianotasi, atau teks naratif per langkah.|Supervisor / SME.|
|**Form/Record**|Bukti Aktivitas.|Template input data (Digital/Print). Menjadi "Record" setelah diisi dan dikunci. 5|Pelaksana Lapangan.|

**Logika Pemilihan (AI Rule):**

* Jika Input melibatkan >1 Role: Sarankan **SOP**.
* Jika Input hanya 1 Role tetapi Kompleksitas > 5 (skala 10): Sarankan **WI**.
* **Penting**: WI harus dapat diakses melalui SOP. Pada UI flowchart SOP, klik pada "Process Box" harus memicu *modal window* yang menampilkan detail WI terkait. 7

## **2. Struktur Dokumen \& Metadata (Validitas Audit)**

Setiap dokumen harus memiliki identitas unik untuk mencegah penggunaan dokumen usang (*obsolete*).9

### **A. Komponen Wajib (Header \& Metadata)**

Sesuai Klausul 7.5.2, identifikasi dokumen harus mencakup title, date, author, dan reference number.11

|Komponen|Aturan Implementasi|Referensi ISO|
|-|-|-|
|**Document ID**|Alfanumerik unik (Contoh: SOP-OPS-001). 11|7.5.2 (a)|
|**Revision Number**|Dimulai dari Rev 00. Setiap perubahan menaikkan angka. 9|7.5.3.2|
|**Page Numbering**|Format wajib: "**Halaman X dari Y**" pada setiap halaman.|Audit Trail|
|**Header Repetition**|Logo, Judul, dan No. Dokumen **wajib diulang** di setiap halaman.|Ketertelusuran|
|**Approvals**|Field nama \& jabatan untuk: Disusun, Diperiksa, Disetujui.|7.5.2 (c)|

### **B. Skema Data JSON (MongoDB/PostgreSQL)**

Implementasi database harus mengikuti skema berikut untuk memfasilitasi jejak audit (audit trail).15

JSON

{  
"doc\_metadata": {  
"doc\_id": "SOP-LOG-005",  
"title": "Prosedur Penerimaan Barang",  
"version": "01",  
"effective\_date": "2026-02-01",  
"status": "Active",  
"owner": "Logistics Manager",  
"iso\_clauses": \["8.5.1", "8.5.2"]  
},  
"revision\_history":,  
"definitions": \[{"term": "FIFO", "definition": "First In First Out"}],  
"related\_docs":  
}

## **3. Logika Flowchart \& Percabangan (ISO 5807)**

AI harus menghasilkan visualisasi yang konsisten secara logika dan teknis.

### **A. Standar Simbol**

17

1. **Terminator (Oval)**: Mulai dan Selesai.
2. **Process (Rectangle)**: Aktivitas tunggal (misal: "Input Data").
3. **Decision (Diamond)**: Titik keputusan. Wajib memiliki dua jalur keluar berlabel ("Ya"/"Tidak" atau "Sesuai"/"Tidak Sesuai").
4. **Document (Wavy Rectangle)**: Jika langkah tersebut menghasilkan formulir atau catatan.

### **B. Menampilkan Percabangan dalam Tabel SOP**

Jika flowchart linear sulit dikonversi ke tabel, gunakan aturan berikut:

* **Nested Numbering**: Gunakan penomoran bertingkat (Contoh: 5.1, 5.2).
* **Hanging Indent**: Langkah subordinat harus menjorok ke dalam (indent) agar secara visual terikat pada langkah keputusan di atasnya.
* **Contoh Tabel**:

|No|Penanggung Jawab|Uraian Kegiatan|Dokumen|
|-|-|-|-|
|5|Staff Gudang|Periksa kesesuaian fisik barang dengan PO.|Form-Cek-01|
|||5.1. Jika sesuai, tanda tangani surat jalan.||
|||5.2. Jika tidak sesuai, buat Laporan Ketidaksesuaian (NCR).|Form-NCR-01|

## **4. Validitas Formulir sebagai "Record" Audit**

Formulir digital hanya sah sebagai bukti audit jika menjamin **Integritas** dan **Ketertelusuran** (Klausul 8.5.2).

* **Elemen Wajib Record**:

  1. **Unique Record ID**: ID unik per transaksi (misal: No. Batch/Lot).
  2. **User Stamp**: Pencatatan otomatis ID pengguna dan Timestamp (Waktu + Tanggal) saat data dikirim.
  3. **Data Locking**: Setelah status "Final", data tidak boleh diubah. Perubahan setelah final harus melalui prosedur "Revision" yang mencatat alasan perubahan (E.E - *Entry Error*).

* **QR Code**: Setiap dokumen cetak disarankan memiliki QR code yang merujuk ke URL versi digital terbaru di sistem untuk memastikan operator tidak menggunakan instruksi yang sudah kadaluwarsa.

## **5. Checklist Kesiapan Audit (GSO/Compliance)**

Programmer harus memastikan sistem secara otomatis memeriksa kelengkapan berikut sebelum dokumen di-publish:

1. **Identitas Lengkap**: ID, Judul, No. Revisi, Tanggal Berlaku tersedia.
2. **Referential Integrity**: Semua WI atau Form yang disebutkan dalam SOP harus ada link/file-nya. 19
3. **Master List**: Sistem harus memiliki "Daftar Induk Dokumen" yang menampilkan status terbaru semua dokumen secara *real-time*.
4. **Distribution Control**: Hak akses ditentukan per departemen atau jabatan (Role-Based Access Control). 8

## **6. Rekomendasi UI/UX untuk Programmer (Mobile-First)**

Mengingat penggunaan di retail (HollyMart) yang dinamis, UI harus meminimalkan kesalahan input:

* **Single-Column Layout**: Untuk formulir di perangkat mobile.
* **Native Controls**: Gunakan *date-picker* dan *numeric keypad* untuk mengurangi typo hingga 35%.
* **Progressive Disclosure**: Sembunyikan field yang tidak relevan. Jika langkah 5.1 dipilih, jangan tampilkan field untuk langkah 5.2.

## **Kesimpulan**

Sistem ini harus beroperasi sebagai **Trusted Source**. Setiap dokumen yang keluar dari HMCS harus memiliki "sidik jari digital" (Metadata) yang lengkap agar saat auditor eksternal bertanya "Bagaimana Anda menjamin ini versi terbaru?", sistem dapat memberikan jawaban berbasis data yang tidak terbantahkan.

#### **Works cited**

1. Clause 7.5 ISO 9001:2015 Explained | Core Business Solutions, accessed January 31, 2026, [https://www.thecoresolution.com/clause-7-5-iso-90012015-explained](https://www.thecoresolution.com/clause-7-5-iso-90012015-explained)
2. Clause 7.5.1 ISO 9001:2015 Explained | Core Business Solutions, accessed January 31, 2026, [https://www.thecoresolution.com/clause-7-5-1-9001-2015-explained](https://www.thecoresolution.com/clause-7-5-1-9001-2015-explained)
3. SOP vs Work Instruction: Key Differences You Need to Know - Whale, accessed January 31, 2026, [https://usewhale.io/blog/sop-vs-work-instruction/](https://usewhale.io/blog/sop-vs-work-instruction/)
4. SOPs vs work instructions - Touch Stay, accessed January 31, 2026, [https://touchstay.com/blog/sops-vs-work-instructions](https://touchstay.com/blog/sops-vs-work-instructions)
5. 7.5 What is Documented Information in ISO 9001? \[with Template], accessed January 31, 2026, [https://www.iso-9001-checklist.co.uk/7.5-what-is-documented-information-in-iso-9001.htm](https://www.iso-9001-checklist.co.uk/7.5-what-is-documented-information-in-iso-9001.htm)
6. Mandatory Documentation as Per ISO 9001:2015 Standard - Effivity, accessed January 31, 2026, [https://www.effivity.com/blog/mandatory-documentation-as-per-iso-90012015-standard](https://www.effivity.com/blog/mandatory-documentation-as-per-iso-90012015-standard)
7. ISO 9001 Processes, Procedures and Work Instructions - 9000 Store, accessed January 31, 2026, [https://the9000store.com/iso-9001-2015-requirements/iso-9001-2015-context-of-the-organization/processes-procedures-work-instructions/](https://the9000store.com/iso-9001-2015-requirements/iso-9001-2015-context-of-the-organization/processes-procedures-work-instructions/)
8. SOP vs WI which one do I need? - by Arboria Solutions - Medium, accessed January 31, 2026, [https://medium.com/@arboriasolutions/sop-vs-wi-which-one-do-i-need-1377b7f0cb1f](https://medium.com/@arboriasolutions/sop-vs-wi-which-one-do-i-need-1377b7f0cb1f)
9. A Complete Guide to ISO 9001 Document Control - Life Science Software - Instem, accessed January 31, 2026, [https://www.instem.com/a-complete-guide-to-iso-9001-document-control/](https://www.instem.com/a-complete-guide-to-iso-9001-document-control/)
10. Criteria Authoring Workbench - CogniSwitch, accessed January 31, 2026, [https://cogniswitch.ai/workshop/criteria-guide](https://cogniswitch.ai/workshop/criteria-guide)
11. Document Control: Definition, Requirements, Components, and Benefits - SimplerQMS, accessed January 31, 2026, [https://simplerqms.com/document-control/](https://simplerqms.com/document-control/)
12. Identification and Traceability - ISO 9000 Store, accessed January 31, 2026, [https://the9000store.com/iso-9001-2015-requirements/iso-9001-2015-operational-requirements/identification-traceability/](https://the9000store.com/iso-9001-2015-requirements/iso-9001-2015-operational-requirements/identification-traceability/)
13. The 5 must-have templates for managing your QMS - Scilife, accessed January 31, 2026, [https://www.scilife.io/blog/templates-managing-qms](https://www.scilife.io/blog/templates-managing-qms)
14. ISO 9001 Clause 8.5.2 Identification \& Traceability: Useful Info, accessed January 31, 2026, [https://www.qualityze.com/blogs/iso-9001-clause-8-5-2-identification-traceability](https://www.qualityze.com/blogs/iso-9001-clause-8-5-2-identification-traceability)
15. List of Mandatory Documents for ISO9001:2015 - CertiKit, accessed January 31, 2026, [https://certikit.com/mandatory-documents-iso9001](https://certikit.com/mandatory-documents-iso9001)
16. 30 Flowchart Symbol Meanings: Shapes \& Uses Explained - MockFlow, accessed January 31, 2026, [https://mockflow.com/blog/flowchart-meaning-and-symbols](https://mockflow.com/blog/flowchart-meaning-and-symbols)
17. ISO 5807 Flowchart Symbols: Complete Guide with Examples (2025), accessed January 31, 2026, [https://www.useworkspace.dk/en/blog/iso-5807-flowchart-symbols-guide](https://www.useworkspace.dk/en/blog/iso-5807-flowchart-symbols-guide)
18. Mobile-Friendly Forms: Why They Matter and How to Build Them - FormStory, accessed January 31, 2026, [https://formstory.io/learn/mobile-friendly-forms/](https://formstory.io/learn/mobile-friendly-forms/)

SOP vs Work Instruction: GMP Compliance Differences - Pharmuni, accessed January 31, 2026, [https://pharmuni.com/2025/03/24/confused-about-sop-vs-work-instruction-unlock-the-clarity/](https://pharmuni.com/2025/03/24/confused-about-sop-vs-work-instruction-unlock-the-clarity/)

