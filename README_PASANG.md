# IbadahKu: Panduan Pasang (VS Code + Flutter)

## 1. Timpa ke project Anda
Salin isi zip ini ke root project `ibadahku` (timpa jika diminta):
`lib/`, `test/logic_test.dart`, `assets/icon/`, `pubspec.yaml`, `analysis_options.yaml`, `firestore.rules`.

- **Jangan timpa** folder `android/`, `windows/` dan file `lib/firebase_options.dart` milik Anda (dibuat oleh `flutterfire configure`).
- Hapus file bawaan `test/widget_test.dart` (merujuk `MyApp`, akan error).
- Jika `pubspec.yaml` lama Anda punya konfigurasi khusus, cukup gabungkan bagian `dependencies`.

## 2. Perintah terminal (urut)
```
flutter pub get
dart run flutter_launcher_icons
flutterfire configure        # pilih project Firebase, platform android (+ windows)
flutter test
flutter run
```
Jika `pub get` mengeluh versi bentrok: `flutter pub upgrade --major-versions`.

## 3. Android (wajib)
**a. Izin internet** di `android/app/src/main/AndroidManifest.xml`, di dalam `<manifest>` sebelum `<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
(Di mode release izin ini TIDAK otomatis ada; tanpa ini APK tidak bisa login.)

**b. Nama aplikasi**: pada tag `<application`, ubah `android:label="IbadahKu"`.

**c. minSdk** di `android/app/build.gradle.kts` (atau `build.gradle`):
```kotlin
defaultConfig { minSdk = 23 }      // Groovy: minSdkVersion 23
```

## 4. Firebase Console
1. Authentication > Sign-in method > aktifkan **Email/Password** saja.
2. Firestore Database > buat (mode produksi) > tab **Rules** > tempel isi `firestore.rules` > Publish.
3. Daftar akun lewat aplikasi, lalu di Firestore `users/{uid}` ubah field `role` menjadi `admin`. Keluar-masuk lagi.
4. Login admin > menu **Harga** > tombol **Buat data awal**, lalu sesuaikan harga emas/beras/hewan (cek BAZNAS).

## 5. Font Poppins (opsional)
Salin `Poppins-Regular/Medium/SemiBold/Bold.ttf` ke `assets/fonts/`, lalu hapus tanda `#` pada blok `fonts:` di `pubspec.yaml`.
Tanpa font ini aplikasi tetap jalan dengan font bawaan.

## 6. APK untuk HKI
```
flutter build apk --release
```
Hasil: `build/app/outputs/flutter-apk/app-release.apk` > ganti nama jadi `IbadahKu.apk`.
Jangan pakai `--split-per-abi` agar tetap 1 file. Uji di HP asli: daftar, login, hitung, simpan riwayat.

## 7. Windows (bonus)
`flutter run -d windows`. Jika gagal, abaikan dulu; APK tidak terpengaruh.

## Asumsi yang dipakai
- Harga awal (emas Rp2,3 jt/g, dll) hanyalah nilai contoh; admin wajib memperbarui.
- Takaran 3,5 liter dianggap setara 2,7 kg. Estimasi daging: kambing/domba 15 kg, sapi 150, kerbau 160, unta 200 kg.
- Default target Idul Adha: 17 Mei 2027 (perkiraan, ubah via date picker).
- Tanggal Hijriah dihitung lokal (bisa selisih 1 hari dari kalender resmi).
- Grafik donat memakai CustomPainter (tanpa fl_chart) supaya ringan dan stabil di Android/Windows.

## Alur logika (untuk laporan)
- **Fitrah**: total = jiwa wajib x takaran (kg) x harga/kg.
- **Maal**: bersih = harta kotor - utang jangka pendek; nisab = 85 g x harga emas; wajib bila bersih >= nisab DAN haul terpenuhi; zakat = bersih x 2,5% (Hijriah) / 2,5775% (Masehi).
- **Qurban**: iuran = (harga + biaya tambahan) / peserta; tabungan per bulan/minggu/hari = kekurangan / sisa periode.
