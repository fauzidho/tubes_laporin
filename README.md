# 📱 LaporIn

<p align="center">
  <h3 align="center">Integrated Campus Facility Reporting System</h3>
  <p align="center">
    Aplikasi Pelaporan Fasilitas Kampus Berbasis Flutter dan Firebase
  </p>
</p>

---

## 📖 Deskripsi Aplikasi

**LaporIn** adalah aplikasi mobile yang dirancang untuk memudahkan mahasiswa dalam melaporkan kerusakan maupun permasalahan fasilitas kampus secara digital. Dengan memanfaatkan teknologi Flutter dan Firebase, aplikasi ini memungkinkan pengguna untuk mengirim laporan secara real-time lengkap dengan foto bukti dan informasi lokasi kerusakan.

Aplikasi ini dikembangkan sebagai **Tugas Besar Mata Kuliah Aplikasi Perangkat Bergerak (APB)** Program Studi Teknologi Informasi, Telkom University.

---

## 🎯 Latar Belakang

Fasilitas kampus merupakan salah satu aspek penting yang mendukung kegiatan belajar mengajar. Namun, proses pelaporan kerusakan fasilitas sering kali masih dilakukan secara manual sehingga informasi tidak tersampaikan dengan cepat dan sulit untuk dipantau perkembangannya.

Untuk mengatasi permasalahan tersebut, dikembangkan aplikasi **LaporIn** sebagai solusi digital yang dapat membantu mahasiswa dan pihak kampus dalam proses pelaporan, monitoring, serta penanganan kerusakan fasilitas secara lebih efektif dan terstruktur.

---

## 🎯 Tujuan Pengembangan

* Mempermudah mahasiswa dalam melaporkan kerusakan fasilitas kampus.
* Meningkatkan kecepatan penyampaian informasi kepada pihak terkait.
* Menyediakan sistem dokumentasi laporan yang terpusat.
* Memudahkan monitoring status penanganan laporan.
* Mendukung digitalisasi layanan kampus.

---

# ✨ Fitur Utama

## 🔐 Authentication System

Pengguna dapat:

* Registrasi akun baru.
* Login menggunakan email dan password.
* Logout dari aplikasi.
* Menyimpan sesi pengguna secara aman menggunakan Firebase Authentication.

---

## 📝 Pelaporan Kerusakan Fasilitas

Pengguna dapat membuat laporan kerusakan dengan mengisi:

* Judul laporan
* Deskripsi kerusakan
* Lokasi kejadian
* Kategori kerusakan
* Foto bukti

Contoh laporan:

* AC tidak berfungsi
* Lampu kelas mati
* Kursi rusak
* Toilet bermasalah
* Kerusakan fasilitas lainnya

---

## 📸 Upload Foto Bukti

Aplikasi menyediakan fitur:

* Mengambil foto langsung dari kamera.
* Memilih gambar dari galeri perangkat.
* Menyimpan gambar ke Firebase Storage.

Tujuan fitur ini adalah memberikan bukti visual yang mendukung laporan sehingga mempermudah proses verifikasi.

---

## 📋 Feed Laporan

Pengguna dapat:

* Melihat daftar laporan yang telah dibuat.
* Melihat detail laporan.
* Melihat tanggal pelaporan.
* Mengetahui status penanganan laporan.

Data ditampilkan secara real-time menggunakan Cloud Firestore.

---

## 🔄 Monitoring Status Laporan

Status laporan dibagi menjadi:

### Pending

Laporan telah dikirim dan menunggu verifikasi.

### In Progress

Laporan sedang ditangani oleh pihak terkait.

### Resolved

Kerusakan telah diperbaiki dan laporan selesai.

---

## 👨‍💼 Admin Dashboard

Admin dapat:

* Melihat seluruh laporan.
* Memperbarui status laporan.
* Memantau progres penanganan.
* Mengelola data laporan yang masuk.

---

# 🏗️ Arsitektur Sistem

```text
+----------------+
|     User       |
+----------------+
        |
        v
+----------------+
| Flutter Mobile |
| Application    |
+----------------+
        |
        v
+-------------------------+
| Firebase Authentication |
+-------------------------+
        |
        v
+-------------------------+
| Cloud Firestore         |
+-------------------------+
        |
        v
+-------------------------+
| Firebase Storage        |
+-------------------------+
```

---

# 🛠️ Teknologi yang Digunakan

## Frontend

* Flutter
* Dart

## Backend & Cloud Services

* Firebase Authentication
* Cloud Firestore
* Firebase Storage

## State Management

* Provider

## User Interface

* Material Design
* Google Fonts
* Cupertino Icons

## Development Tools

* Visual Studio Code
* Android Studio
* Git
* GitHub

---

# 📂 Struktur Project

```text
lib/
├── models/
├── providers/
├── screens/
├── services/
├── widgets/
├── utils/
└── main.dart

assets/
├── images/
└── icons/

android/
ios/
web/
```

---

# 🔄 Alur Penggunaan Aplikasi

1. Pengguna melakukan registrasi akun.
2. Pengguna login ke aplikasi.
3. Pengguna membuat laporan kerusakan.
4. Pengguna menambahkan foto bukti.
5. Data laporan disimpan ke Firebase.
6. Admin menerima laporan.
7. Admin melakukan verifikasi.
8. Status laporan diperbarui.
9. Pengguna memantau perkembangan laporan secara real-time.

---

# 📊 Keunggulan Aplikasi

✅ Mudah digunakan

✅ Tampilan modern dan responsif

✅ Penyimpanan data berbasis cloud

✅ Monitoring laporan secara real-time

✅ Dokumentasi laporan lebih terstruktur

✅ Mendukung transformasi digital kampus

# ⚙️ Cara Menjalankan Project

### Clone Repository

```bash
git clone https://github.com/username/laporin.git
```

### Masuk ke Folder Project

```bash
cd laporin
```

### Install Dependencies

```bash
flutter pub get
```

### Jalankan Aplikasi

```bash
flutter run
```

---

# 📋 Persyaratan Sistem

* Flutter SDK 3.5 atau lebih baru
* Dart SDK
* Android Studio
* Visual Studio Code
* Firebase Project

---

# 👥 Tim Pengembang

Project ini dikembangkan oleh mahasiswa Program Studi Teknologi Informasi, Telkom University.

| No | Nama                        |
| -- | --------------------------- |
| 1  | Mohamad Arrayan Abdurachman |
| 2  | Fauzi Ridho Anshori         |
| 3  | Fazla Dwika Simahate        |
| 4  | Dinda Zahira Hasibuan       |
| 5  | Dymaz Galayudha Putra       |

---

# 🎓 Informasi Akademik

**Nama Project :** LaporIn

**Mata Kuliah :** Aplikasi Perangkat Bergerak (APB)

**Program Studi :** Teknologi Informasi

**Universitas :** Telkom University

**Tahun :** 2026

---

# 🚀 Pengembangan Selanjutnya

Fitur yang dapat dikembangkan pada versi berikutnya:

* Notifikasi real-time
* Sistem komentar pada laporan
* Tracking lokasi menggunakan GPS
* Dashboard berbasis web
* Statistik laporan
* Integrasi QR Code lokasi fasilitas

---

# 📄 Lisensi

Project ini dibuat untuk keperluan akademik dan pembelajaran pada Mata Kuliah Aplikasi Perangkat Bergerak (APB).

© 2026 LaporIn Team - Telkom University
