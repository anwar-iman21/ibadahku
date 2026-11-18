# IbadahKu

## 1. Ringkasan Proyek

IbadahKu adalah aplikasi lintas platform berbasis Flutter untuk membantu pengguna membuat estimasi perhitungan zakat fitrah, zakat maal, dan perencanaan biaya qurban. Aplikasi menyediakan akun pengguna dan admin, harga acuan yang dapat dikelola admin, konten tips ibadah, serta riwayat perhitungan yang disimpan di cloud.

Perhitungan dilakukan oleh aplikasi berdasarkan masukan pengguna dan nilai acuan yang tersedia. Hasilnya merupakan **estimasi**, bukan fatwa atau penetapan kewajiban yang mengikat. Pengguna dianjurkan untuk memeriksa harga terkini dan berkonsultasi dengan BAZNAS/LAZ atau ahli yang tepercaya.

| Informasi | Keterangan |
|---|---|
| Nama aplikasi | IbadahKu |
| Versi saat ini | 1.0.0+1 |
| Platform | Flutter; konfigurasi Firebase tersedia untuk Android, iOS, macOS, web, dan Windows |
| Bahasa antarmuka | Bahasa Indonesia |
| Backend | Firebase Authentication dan Cloud Firestore |
| Status | Prototipe/MVP dengan fitur inti; masih memerlukan validasi, pengujian, dan penyempurnaan sebelum penggunaan luas |

## 2. Latar Belakang

Pengguna sering perlu memperkirakan kewajiban zakat dan biaya qurban dengan memasukkan beberapa data, seperti jumlah anggota keluarga, jenis harta, harga acuan, biaya tambahan, atau target waktu. IbadahKu menggabungkan kalkulator sederhana dan penyimpanan riwayat dalam satu aplikasi agar proses estimasi lebih mudah ditinjau kembali.

Harga dan informasi yang digunakan dapat berubah dari waktu ke waktu. Karena itu, aplikasi menyediakan fitur admin untuk memperbarui sebagian harga acuan dan mengelola tips yang ditampilkan kepada pengguna.

## 3. Tujuan

1. Menyediakan alat bantu untuk menghitung estimasi zakat fitrah dan zakat maal.
2. Membantu pengguna merencanakan biaya, patungan, dan tabungan qurban.
3. Menyimpan riwayat hasil perhitungan agar dapat dilihat kembali.
4. Menyediakan pengelolaan harga acuan dan konten informasi melalui akun admin.
5. Menyampaikan asumsi dan batasan perhitungan secara terbuka kepada pengguna.

## 4. Pengguna dan Hak Akses

### Pengguna

- Mendaftar dan masuk dengan username serta password.
- Mengubah nama profil dan password dari halaman Akun.
- Melihat halaman beranda, harga acuan, dan tips aktif.
- Menggunakan kalkulator zakat fitrah, zakat maal, dan qurban.
- Menyimpan, melihat, membagikan, memfilter, dan menghapus riwayat miliknya.
- Membuka panduan ibadah, FAQ/bantuan, kebijakan privasi, dan syarat penggunaan.
- Keluar dari akun.

### Admin

Admin memiliki halaman dashboard, pengelolaan harga, pengelolaan konten tips, daftar pengguna, dan halaman akun. Admin dapat memperbarui harga acuan serta menambah, mengubah, menonaktifkan, atau menghapus tips. Pengaturan hak admin saat ini dilakukan secara manual melalui Firebase Console; pendaftaran baru selalu menghasilkan akun dengan peran `user`.

## 5. Fitur yang Telah Diimplementasikan

### 5.1 Autentikasi dan profil

- Registrasi dan login menggunakan Firebase Authentication dengan metode Email/Password.
- Form aplikasi menggunakan username. Username diubah menjadi alamat email internal berformat `<username>@ibadahku.app` untuk proses Firebase Authentication.
- Profil pengguna disimpan di Firestore pada `users/{uid}`, termasuk username, nama lengkap, peran, dan waktu pembuatan.
- Nama profil dapat diubah dari aplikasi; username login tidak dapat diubah.
- Password dapat diganti setelah memasukkan password saat ini. Reset melalui email bergantung pada tersedianya mailbox untuk alamat internal akun.
- Aplikasi membedakan alur pengguna dan admin berdasarkan nilai `role`.

### 5.2 Beranda

- Menampilkan sapaan, tanggal Masehi, dan tanggal Hijriah hasil perhitungan lokal.
- Menampilkan sebagian harga acuan, yaitu harga emas dan beras medium, berikut status/tanggal pembaruan jika tersedia.
- Menyediakan pintasan ke kalkulator zakat dan qurban.
- Menampilkan hingga tiga riwayat terbaru dan hingga enam tips aktif.

### 5.3 Kalkulator zakat fitrah

- Mendukung masukan jumlah jiwa atau daftar anggota keluarga.
- Daftar anggota mengenali kategori dewasa, anak, bayi lahir sebelum maghrib, dan bayi lahir setelah maghrib. Bayi yang lahir setelah maghrib akhir Ramadhan tidak dihitung dalam jumlah wajib oleh aturan aplikasi.
- Mendukung pilihan takaran 2,5 kg, 2,7 kg, atau 3,5 liter.
- Mendukung jenis beras medium, premium, super, atau harga custom.
- Menampilkan estimasi pembayaran dalam uang atau beras.
- Hasil dapat disimpan ke riwayat dan dibagikan sebagai teks.

Rumus dasar yang dipakai:

```text
Jumlah beras (kg) = jumlah jiwa wajib × takaran beras per jiwa
Estimasi uang = jumlah beras (kg) × harga beras per kg
```

Dalam implementasi saat ini, pilihan 3,5 liter menggunakan ekuivalensi asumsi sekitar 2,7 kg untuk perhitungan berat. Nilai ini perlu disesuaikan dengan pedoman yang dipilih.

### 5.4 Kalkulator zakat maal

- Meminta harga emas dan, jika digunakan, harga perak.
- Mencakup uang tunai/tabungan, deposito/giro, emas, perak, investasi, piutang lancar, aset perdagangan, properti/kendaraan tertentu, penghasilan terkumpul, dan harta produktif lain.
- Memperhitungkan utang sebagai pengurang sesuai masukan.
- Menyediakan pilihan tahun Hijriah atau Masehi dan pemeriksaan haul melalui pilihan status atau tanggal mulai kepemilikan.
- Menampilkan ringkasan total harta, harta bersih, nisab, status, dan estimasi zakat.
- Hasil dapat disimpan dan dibagikan.

Rumus inti pada implementasi saat ini:

```text
Harta bersih = max(total harta yang dihitung - utang, 0)
Nisab emas = 85 gram × harga emas per gram
Status wajib = harta bersih mencapai nisab DAN haul terpenuhi
Zakat = harta bersih × tarif
Tarif Hijriah = 2,5%; tarif Masehi = 2,5775%
```

Catatan: model juga menghitung nilai nisab perak, tetapi penentuan status wajib yang dipakai saat ini membandingkan harta bersih dengan nisab emas. Perlakuan terhadap perak, aset, utang, dan haul perlu ditinjau bersama rujukan agama/otoritas yang dipilih sebelum dianggap sebagai panduan final.

### 5.5 Kalkulator qurban

- Mendukung jenis hewan kambing, domba, sapi, kerbau, dan unta.
- Menggunakan harga hewan acuan dari admin sebagai nilai awal, yang masih dapat disesuaikan di form.
- Memperhitungkan biaya transportasi, pemotongan, administrasi, dan biaya lainnya.
- Menghitung iuran per peserta dengan batas peserta sesuai jenis hewan pada aplikasi.
- Menghitung kekurangan tabungan dan estimasi tabungan per hari, minggu, atau bulan sampai tanggal target.
- Menampilkan estimasi pembagian daging dan mendukung penyimpanan serta berbagi ringkasan hasil.

Rumus utama:

```text
Total biaya = harga hewan + seluruh biaya tambahan
Iuran per peserta = total biaya ÷ jumlah peserta
Kekurangan = max(iuran per peserta - tabungan saat ini, 0)
Tabungan per periode = kekurangan ÷ sisa periode
```

Perkiraan berat daging dan beberapa keterangan terkait hewan merupakan asumsi. Pembagian daging yang ditampilkan sebagai estimasi tidak menggantikan panduan syariat atau kondisi aktual hewan.

### 5.6 Riwayat dan berbagi

- Riwayat disimpan di Firestore dan dikaitkan dengan UID pemilik.
- Mendukung filter semua, fitrah, maal, dan qurban.
- Pengguna dapat melihat detail, membagikan ringkasan, menghapus satu item, atau menghapus semua riwayatnya.
- Jika perangkat/platform tidak dapat menggunakan fitur berbagi, teks hasil dapat disalin ke clipboard.

### 5.7 Fitur admin

- **Dashboard:** ringkasan jumlah pengguna, seluruh perhitungan, fitrah, maal, dan qurban.
- **Harga:** mengelola harga emas/perak, beras medium/premium/super, serta harga kambing, domba, sapi, kerbau, dan unta. Admin dapat membuat data harga awal.
- **Konten:** mengelola judul dan isi tips, mengatur status aktif/nonaktif, dan menghapus tips.
- **Pengguna:** menampilkan daftar pengguna untuk dibaca admin.
- **Akun:** menampilkan profil/peran, mengubah nama/password, membuka panduan dan informasi kebijakan, serta keluar.

### 5.8 Panduan dan informasi

- Halaman di dalam aplikasi berisi ringkasan niat dan tata cara zakat fitrah, zakat maal, dan qurban.
- FAQ menjelaskan penggunaan akun dan penyimpanan riwayat.
- Kebijakan privasi dan syarat penggunaan menjelaskan pemrosesan data Firebase serta batasan estimasi aplikasi.
- Konten panduan bersifat informatif, bukan fatwa; rujuk lembaga/ahli yang berwenang untuk kepastian.

### 5.9 Gambar kategori, tampilan, dan akses

- Aplikasi menggunakan tema terang.
- Antarmuka menggunakan tata letak responsif dan komponen desain bersama.
- Gambar kategori memakai bingkai oval dan dipilih otomatis berdasarkan jenis perhitungan, termasuk di riwayat.
- JPG kategori yang dipakai: `kakulator-zakat.jpg` untuk kalkulator zakat, `kalkulator-qurban.jpg` untuk qurban, `zakat fitrah.jpg` untuk fitrah, dan `zakat-mal.jpg` untuk maal. Simpan di `assets/icons/`; pemetaan path berada di `CategoryImage` pada `lib/design_system/app_misc.dart`.
- Riwayat tidak menyimpan salinan gambar per item; jenis riwayat menentukan JPG yang ditampilkan. Setelah menambahkan JPG, restart atau build ulang aplikasi.

## 6. Arsitektur dan Teknologi

### Teknologi utama

- **Flutter/Dart:** antarmuka aplikasi dan logika kalkulator.
- **Firebase Authentication:** autentikasi pengguna dengan Email/Password.
- **Cloud Firestore:** profil, harga, tips, dan riwayat.
- **Provider:** state management dan distribusi status/data ke halaman.
- **GoRouter:** navigasi dan pengalihan berdasarkan status login/peran.
- **share_plus:** berbagi ringkasan hasil perhitungan.
- **intl:** format tanggal/angka dan kebutuhan lokalisasi.
- **flutter_animate:** animasi antarmuka.

### Alur data

1. Saat aplikasi dimulai, Firebase diinisialisasi.
2. `AuthProvider` memantau perubahan status autentikasi, lalu memuat profil Firestore untuk menentukan peran akun.
3. `GoRouter` mengarahkan pengguna yang belum login ke halaman autentikasi dan mengarahkan akun sesuai perannya.
4. Provider data berlangganan pada harga, tips, dan riwayat Firestore untuk memperbarui antarmuka.
5. Logika kalkulator berjalan di sisi aplikasi; hasil baru ditulis ke Firestore apabila pengguna memilih menyimpannya.
6. Ringkasan hasil perhitungan dapat dibagikan melalui menu berbagi perangkat.

### Struktur folder utama

```text
lib/
  design_system/  Komponen, warna, tipografi, tema, dan tata letak
  logic/          Logika kalkulator fitrah, maal, dan qurban
  models/         Model profil, harga, tips, riwayat, dan statistik
  providers/      State autentikasi, data, dan tema
  routes/         Konfigurasi navigasi aplikasi
  screens/
    admin/        Halaman admin
    auth/         Splash, login, dan registrasi
    user/         Halaman pengguna dan kalkulator
  services/       Integrasi Firebase Authentication dan Firestore
  utils/          Format, validasi, tanggal Hijriah, dialog, dan berbagi
  widgets/        Widget yang digunakan ulang
test/
  logic_test.dart Pengujian logika kalkulator dan utilitas
```

## 7. Struktur Data Firestore

| Koleksi/dokumen | Isi utama |
|---|---|
| `users/{uid}` | `username`, `namaLengkap`, `role`, `createdAt` |
| `settings/prices` | Harga emas/perak, harga beberapa jenis beras, dan harga hewan qurban; dapat berisi `updatedAt` |
| `tips/{tipId}` | `judul`, `isi`, `aktif`, `createdAt` |
| `history/{historyId}` | UID pemilik, jenis perhitungan, masukan, hasil, dan waktu pembuatan |

Aturan keamanan Firestore disediakan dalam `firestore.rules`. Secara garis besar, aturan membatasi profil pengguna agar dapat dibaca pemiliknya atau admin, harga dan tips hanya dapat ditulis admin, dan riwayat dibatasi kepada pemilik serta admin sesuai operasi yang diizinkan. Aturan tersebut harus dipublikasikan ke Firebase Console dan ditinjau ulang sebelum aplikasi dipakai pada lingkungan produksi.

Firestore offline persistence diaktifkan dalam kode untuk mendukung cache/sinkronisasi pada platform yang didukung. Ketersediaan dan perilakunya dapat berbeda per platform; fitur offline penuh tidak dijanjikan untuk semua alur aplikasi.

## 8. Asumsi dan Batasan Saat Ini

- Harga bawaan merupakan **nilai contoh**, bukan harga pasar resmi. Admin perlu memperbaruinya dan memeriksa tanggal/sumber sebelum digunakan.
- Jika dokumen harga belum dibuat, aplikasi menggunakan nilai default. Pengguna dapat melihat penanda bahwa harga masih nilai awal.
- Ekuivalensi 3,5 liter menjadi sekitar 2,7 kg adalah asumsi implementasi.
- Perkiraan berat daging yang digunakan: kambing/domba 15 kg, sapi 150 kg, kerbau 160 kg, dan unta 200 kg.
- Tanggal target qurban bawaan adalah 17 Mei 2027, berupa perkiraan dan dapat diubah.
- Tanggal Hijriah dihitung lokal dengan algoritma Kuwaiti dan dapat berbeda sekitar satu hari dari kalender resmi.
- Semua hasil adalah estimasi; aplikasi belum menyediakan verifikasi hukum/agama ataupun validasi data dari sumber eksternal.
- Akun admin dipromosikan secara manual melalui Firebase Console. Tidak ada alur undangan atau pengelolaan peran admin dari aplikasi.
- Belum terdapat fitur unggah file/dokumen/foto pengguna maupun integrasi Firebase Storage.
- Akun yang sudah ada menggunakan alamat Firebase sintetis `<username>@ibadahku.app`, bukan email pribadi. Ganti password memerlukan sesi login dan password saat ini.
- Ketersediaan cache Firestore tidak sama dengan jaminan semua tindakan dapat diselesaikan offline.

## 9. Pengujian

Pengujian unit yang tersedia mencakup kasus-kasus logika zakat fitrah, zakat maal, qurban, konversi tanggal Hijriah, format angka, serta validasi username.

Untuk menjalankan pengujian logika:

```bash
flutter test test/logic_test.dart
```

Untuk menjalankan seluruh pengujian proyek:

```bash
flutter test
```

Pengembangan selanjutnya sebaiknya menambahkan pengujian widget, alur autentikasi, integrasi Firestore, aturan keamanan, dan pengujian pada perangkat/platform target.

## 10. Persiapan dan Menjalankan Aplikasi

### Prasyarat

- Flutter SDK yang sesuai dengan batas SDK pada `pubspec.yaml` (Dart `^3.7.0`).
- Android Studio/Xcode atau toolchain platform yang akan dijalankan.
- Project Firebase dengan Authentication dan Cloud Firestore.
- FlutterFire CLI untuk konfigurasi Firebase apabila menghubungkan aplikasi ke project Firebase baru.

### Langkah awal

```bash
flutter pub get
```

Pastikan konfigurasi Firebase platform tersedia. Konfigurasi aplikasi saat ini berada di `lib/firebase_options.dart`; berkas konfigurasi native seperti `android/app/google-services.json` juga diperlukan untuk platform terkait. Jika memakai project Firebase sendiri, jalankan:

```bash
flutterfire configure
```

Di Firebase Console:

1. Aktifkan provider **Authentication > Email/Password**.
2. Buat Cloud Firestore.
3. Publikasikan aturan dari `firestore.rules`.
4. Jalankan aplikasi dan daftarkan akun melalui halaman registrasi.
5. Jika perlu membuat admin, buka dokumen `users/{uid}` akun yang benar lalu ubah field string `role` dari `user` menjadi `admin`. Jangan membuat koleksi `admin` baru.
6. Keluar lalu masuk kembali agar peran dimuat ulang.
7. Dari menu admin, buat data harga awal dan perbarui nilainya dengan harga yang telah diverifikasi.

Untuk menjalankan aplikasi pada perangkat yang terdeteksi:

```bash
flutter run
```

Untuk menjalankan pada Windows desktop, apabila toolchain Windows telah tersedia:

```bash
flutter run -d windows
```

Panduan setup yang lebih terperinci, termasuk catatan konfigurasi Android dan pembuatan APK, tersedia di [README_PASANG.md](README_PASANG.md).

## 11. Rencana Pengembangan

### Prioritas 1 — Validitas dan transparansi

- Meninjau rumus, kategori harta, haul, nisab, serta asumsi fitrah/qurban dengan sumber resmi atau ahli.
- Menjelaskan sumber harga, waktu pembaruan, metode perhitungan, dan asumsi pada halaman hasil.
- Menambahkan pengujian untuk batas nilai, kasus tepi, dan pembulatan hasil.

### Prioritas 2 — Keamanan dan pengelolaan akun

- Meninjau aturan Firestore dengan skenario akses untuk pengguna biasa dan admin.
- Mengembangkan pengelolaan peran admin dengan proses yang lebih terkontrol dan dapat diaudit.
- Meninjau proteksi data pribadi, kebijakan privasi, dan proses penghapusan akun/data.

### Prioritas 3 — Pengalaman pengguna dan ketahanan

- Menambahkan status koneksi dan status sinkronisasi riwayat yang lebih jelas.
- Menambahkan pengujian integrasi serta memperbaiki alur ketika Firebase tidak tersedia.
- Meningkatkan aksesibilitas dan uji coba pada perangkat/ukuran layar berbeda.
- Mengevaluasi performa dan strategi pemuatan riwayat ketika volume data tumbuh.

### Prioritas 4 — Fitur lanjutan

- Menambahkan fitur pencarian dan filter lanjutan untuk riwayat.
- Jika benar-benar dibutuhkan, menambahkan unggah dokumen melalui layanan penyimpanan cloud dengan validasi dan aturan akses yang sesuai.
- Menyiapkan proses rilis, pemantauan, pencadangan, dan dokumentasi operasional.

## 12. Kesimpulan

IbadahKu telah memiliki fitur utama untuk estimasi zakat fitrah, zakat maal, dan perencanaan qurban, dilengkapi autentikasi, penyimpanan riwayat, harga acuan, konten tips, dan halaman admin. Arsitektur Flutter dan Firebase memungkinkan antarmuka aplikasi berkomunikasi dengan autentikasi serta database cloud.

Proyek ini masih layak dipandang sebagai prototipe/MVP. Sebelum digunakan lebih luas, pekerjaan yang paling penting adalah memvalidasi metode perhitungan, meninjau keamanan dan privasi, menyediakan alamat pemulihan akun yang dapat diakses, serta memperluas pengujian. Setiap hasil kalkulator harus tetap disampaikan sebagai estimasi dan tidak menggantikan konsultasi kepada lembaga atau ahli yang berwenang.
