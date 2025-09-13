# Blueprint Aplikasi Restoran

## Ringkasan

Aplikasi Flutter ini menampilkan daftar restoran dari sebuah API, memungkinkan pengguna untuk melihat detail, mencari, menambahkan ke favorit, dan memberikan ulasan. Aplikasi ini dirancang dengan arsitektur yang bersih, manajemen state menggunakan Provider, dan fokus pada pengalaman pengguna yang modern dan responsif.

## Desain & Fitur Utama

### 1. Arsitektur & Manajemen State
- **Provider**: Digunakan sebagai solusi utama untuk manajemen state dan *dependency injection*.
  - `RestaurantProvider`: Mengelola pengambilan data (daftar, detail, pencarian) dan status UI (loading, success, error).
  - `SettingsProvider`: Mengelola preferensi pengguna, seperti status pengingat harian.
  - `ThemeProvider`: Mengelola tema aplikasi (terang/gelap).
  - `DbProvider`: Mengelola operasi database lokal untuk fitur favorit.
- **Pemisahan Logika**: Kode dipisahkan menjadi beberapa layer: `data` (models, services), `providers` (state), `screens` (UI), dan `widgets` (komponen UI yang dapat digunakan kembali).
- **Penanganan Error**: Status UI yang jelas untuk loading, error (dengan tombol coba lagi), dan data kosong di semua bagian aplikasi.

### 2. Antarmuka Pengguna (UI) & Desain
- **Tema Modern**: Menggunakan `ThemeData` dengan `ColorScheme.fromSeed` untuk palet warna Material 3 yang konsisten.
- **Tipografi**: Menggunakan `google_fonts` untuk tipografi yang bersih dan mudah dibaca.
- **Komponen Kustom**: Widget seperti `RestaurantCard`, `CustomErrorWidget`, `FavoriteButton`, dan `ReviewSection` dibuat untuk konsistensi dan penggunaan kembali.
- **Animasi Hero**: Transisi yang mulus saat membuka detail restoran dari daftar menggunakan `Hero` widget pada gambar.
- **UI Responsif**: Tata letak dirancang untuk beradaptasi dengan baik di berbagai ukuran layar, terutama pada perangkat mobile.

### 3. Fitur Fungsional
- **Daftar Restoran**: Menampilkan daftar restoran dengan gambar, nama, kota, dan rating.
- **Detail Restoran**: Halaman detail yang kaya fitur, menampilkan gambar besar, deskripsi, kategori, menu makanan & minuman, serta ulasan pelanggan.
- **Pencarian**: Fitur pencarian *real-time* untuk menemukan restoran berdasarkan nama.
- **Favorit**: Pengguna dapat menambahkan atau menghapus restoran dari daftar favorit mereka. Data favorit disimpan secara lokal menggunakan database `sqflite`.
- **Ulasan**: Pengguna dapat mengirim ulasan baru untuk restoran, yang akan langsung ditampilkan di halaman detail.
- **Pengaturan**:
  - **Toggle Tema**: Mengubah antara mode terang dan gelap.
  - **Pengingat Harian**: Notifikasi harian pada jam 11:00 AM yang merekomendasikan restoran secara acak. Menggunakan `flutter_local_notifications` dan `android_alarm_manager_plus`.

## Perubahan & Implementasi Terbaru

### **Perbaikan `PlatformException` untuk Pengingat Harian di Android**

- **Masalah**: Aplikasi mengalami crash (`PlatformException: exact_alarm_not_permited`) saat mencoba mengaktifkan pengingat harian di Android 12+.
- **Penyebab**: Perubahan kebijakan keamanan Android yang memerlukan izin eksplisit dari pengguna untuk menjadwalkan alarm yang presisi (`SCHEDULE_EXACT_ALARM`).
- **Solusi yang Diimplementasikan**:
  1.  **Menambahkan Izin di Manifest**: Izin `<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />` ditambahkan ke `android/app/src/main/AndroidManifest.xml`.
  2.  **Logika Pemeriksaan Izin Proaktif**:
      - Di `lib/screens/settings_screen.dart`, alur pengaktifan pengingat dirombak total.
      - Saat pengguna mengaktifkan *toggle*, aplikasi kini **pertama-tama memeriksa** status izin `Permission.scheduleExactAlarm` menggunakan package `permission_handler`.
      - **Jika izin belum diberikan**, aplikasi akan menampilkan `AlertDialog` yang sopan. Dialog ini menjelaskan mengapa izin "Alarm & Pengingat" diperlukan dan menyediakan tombol **"Buka Pengaturan"** yang mengarahkan pengguna langsung ke halaman pengaturan sistem aplikasi.
      - **Jika izin sudah diberikan**, aplikasi akan melanjutkan alur normal untuk meminta izin notifikasi dasar dan menjadwalkan alarm.
- **Hasil**: Mencegah aplikasi dari crash dan memberikan panduan yang jelas kepada pengguna, secara signifikan meningkatkan pengalaman pengguna dan keandalan fitur.
