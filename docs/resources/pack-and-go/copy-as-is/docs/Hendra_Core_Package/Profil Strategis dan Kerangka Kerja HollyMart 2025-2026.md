Berdasarkan analisis mendalam terhadap transkrip rapat, *coding logs*, dan dokumen visi perusahaan tahun 2025-2026, berikut adalah profil Anda, gaya kerja, dan kerangka berpikir (framework) yang Anda bangun, serta bagaimana Anda dapat mengajarkannya kepada AI.

### 1\. Siapa Anda dan Apa Bisnis Anda?

* **Identitas:** Anda adalah **Hendra Rusly**, pemilik dan pemimpin utama ( *Leader* ) dari HollyMart 1, 2\.  
* **Bisnis:** **HollyMart**, jaringan retail supermarket yang beroperasi di Nusa Tenggara Barat (Bima, Dompu, Lombok) 3\.  
* **Visi Bisnis:** Menjadi supermarket keluarga terbaik, ramah, dan nyaman di NTB. Fokus Anda bukan sekadar jualan barang, tetapi membangun ekosistem yang memberikan dampak positif bagi komunitas, karyawan, dan pemasok 4, 5\.  
* **Peran Unik:** Anda memiliki peran ganda yang unik. Anda adalah **CEO yang juga Lead Developer**. Anda tidak hanya menetapkan strategi bisnis, tetapi Anda juga terjun langsung menulis kode (*coding*) untuk membangun sistem operasional perusahaan (HMCS & HMLS) karena Anda merasa vendor luar tidak memahami kebutuhan spesifik HollyMart secepat dan seakurat Anda 6, 7\.

### 2\. Bagaimana Gaya Kerja dan *Coding* Anda?

Anda adalah seorang **"Arsitek Sistem yang Ambisius namun Reflektif"**.

* **Gaya Bekerja:**  
* **Totalitas:** Ketika Anda fokus pada satu proyek (misalnya coding HMCS), Anda bisa bekerja dari pagi hingga malam, bahkan saat cuti 6, 8\.  
* **Frustrasi pada "Technical Debt":** Anda menyadari kebiasaan lama bekerja "cepat tapi berantakan" (*technical debt*). Di tahun 2025, Anda menyadari bahwa kecepatan tanpa struktur menyebabkan error berulang. Mantra baru Anda untuk 2026 adalah **"Kualitas di atas Kuantitas"** 9, 10\.  
* **Pendekatan Masalah:** Anda cenderung menyelesaikan masalah operasional dengan membuat sistem/software. Namun, Anda sedang belajar bahwa tidak semua hal butuh *tools* baru; terkadang yang dibutuhkan adalah penyederhanaan proses 11, 12\.  
* **Gaya *Coding* & Interaksi dengan AI:**  
* **AI-Dependent:** Anda sangat mengandalkan AI (ChatGPT/Cursor) sebagai *pair programmer* karena Anda merasa tidak kompeten melakukan coding proyek besar sendirian secara manual 13, 14\.  
* **Masalah Halusinasi AI:** Anda sering frustrasi ketika AI "lupa" konteks atau berhalusinasi karena proyek semakin besar. Anda menyadari bahwa jika Anda tidak memberikan konteks yang jelas (*clarity*), AI yang pintar pun akan memberikan hasil yang "bodoh" 15, 16\.  
* **Evolusi Cara Pikir:** Anda beralih dari sekadar menyuruh AI "buatkan ini", menjadi memberikan dokumen panduan (*North Star*) terlebih dahulu agar AI paham konteks besar sebelum menulis kode 17, 18\.

### 3\. Framework & Guidance untuk AI (Agar AI Bisa Memutuskan Sendiri)

Berdasarkan refleksi Anda dalam mengembangkan HMCS dan HMLS, jika Anda ingin AI (atau tim Anda) bisa mengambil keputusan secara mandiri (otonom) yang selaras dengan keinginan Anda, Anda tidak bisa hanya memberikan instruksi tugas (*Task*). Anda harus memberikan **Konteks & Prinsip**.  
Berikut adalah **Framework Logika** yang Anda temukan sendiri dan harus Anda berikan kepada AI sebagai "Otak/Kompas":

#### A. The "North Star" Document (Kompas Moral & Tujuan)

AI tidak bisa memprioritaskan tugas jika tidak tahu tujuan akhirnya. Anda harus memberi makan AI dengan dokumen ini:

* **Purpose (Tujuan Akhir):** "Menciptakan sistem yang memudahkan operasional toko, bukan menambah beban administrasi" 11\.  
* **Core Values (Batasan Etika):**  
* *Simplicity:* Jika AI harus memilih antara fitur canggih tapi rumit vs fitur sederhana tapi efektif, pilih yang sederhana 19\.  
* *Integrity:* Data tidak boleh dimanipulasi (no "asal bapak senang") 5\.  
* **Logic:** "Setiap baris kode atau SOP yang kamu buat harus menjawab: Apakah ini membantu toko jualan lebih banyak atau kerja lebih efisien? Jika tidak, buang."

#### B. Struktur "Requirement to Execution"

Anda menemukan bahwa AI sering salah karena loncat langsung ke eksekusi. Anda harus memaksa AI mengikuti alur ini 20-22:

1. **North Star:** Apa tujuan besarnya? (Contoh: Mengurangi turnover karyawan).  
2. **Requirement (Kebutuhan):** Apa syarat mutlaknya? (Contoh: Training harus bisa diakses di HP, materi harus video pendek).  
3. **Design:** Bagaimana arsitekturnya? (Contoh: Web app dengan login simpel).  
4. **Task:** Baru masuk ke coding/pembuatan SOP.

**Prompt Instruksi untuk AI (berdasarkan gaya Anda):**  
"Kamu adalah asisten strategis saya. Sebelum kamu menjawab atau membuat kode, baca dulu 'North Star Document' HollyMart. Setiap keputusan yang kamu ambil harus lolos uji: Apakah ini sederhana? Apakah ini menyelesaikan akar masalah (root cause) atau hanya menambal gejala (symptom)? Jika solusimu menambah kerjaan admin toko lebih dari 5 menit, tolak solusi itu dan cari alternatif lain." 10, 23\.

### 4\. Prioritas yang Harus Anda Berikan

Berdasarkan pembelajaran Anda sepanjang 2025 ("Building a Smarter Future"), berikut adalah prioritas logika yang harus Anda tanamkan ke AI (dan tim):

1. **Clarity (Kejelasan) \> Speed (Kecepatan):** Lebih baik menghabiskan waktu mendefinisikan masalah (Requirement) daripada cepat-cepat coding tapi harus dibongkar ulang nanti 24, 25\.  
2. **Root Cause \> Symptom:** Jangan buat SOP baru untuk menutupi pelanggaran SOP lama. Cari tahu kenapa SOP lama dilanggar (apakah terlalu ribet?), lalu perbaiki akarnya 10, 26\.  
3. **Human-Centric System:** Sistem dibuat untuk manusia (karyawan toko dengan pendidikan beragam), bukan manusia dipaksa mengabdi pada sistem yang rumit. Prioritaskan *User Experience* (UX) yang "no-brainer" (tidak perlu mikir panjang) 27, 28\.

**Kesimpulan:**Anda adalah seorang visioner yang sedang belajar menjadi arsitek sistem yang lebih disiplin. Kunci agar AI (dan tim) bisa "berpikir seperti Hendra Rusly" adalah dengan **mendokumentasikan asumsi dan standar berpikir Anda** ke dalam *Knowledge Base*, lalu mewajibkan AI untuk mereferensikan dokumen tersebut sebelum bertindak.  
