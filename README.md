# Aplikasi Kamera & Notifikasi Flutter

Aplikasi sederhana berbasis Flutter yang memungkinkan pengguna untuk mengambil gambar menggunakan **Kamera** atau memilih gambar dari **Galeri**. Setelah gambar berhasil dimuat dan ditampilkan di layar, aplikasi akan secara otomatis memunculkan **Notifikasi Lokal** (Push Notification) sebagai konfirmasi keberhasilan.

## 🚀 Fitur Utama

* **Akses Kamera:** Mengambil foto secara langsung menggunakan kamera perangkat.
* **Akses Galeri:** Memilih foto yang sudah ada di penyimpanan perangkat.
* **Notifikasi Lokal:** Menampilkan *heads-up notification* sesaat setelah foto berhasil dimuat.

## 🛠️ Konfigurasi & Setup

Agar aplikasi dapat berjalan dengan baik dan memiliki izin akses ke perangkat keras Android, pastikan kamu telah menambahkan konfigurasi berikut pada project-mu:

### 1. Dependensi (`pubspec.yaml`)
Tambahkan *package* `image_picker` untuk mengambil gambar dan `flutter_local_notifications` untuk menampilkan notifikasi.

```yaml
dependencies:
  flutter:
    sdk: flutter
  image_picker: ^1.1.1
  flutter_local_notifications: ^17.1.2
```
### 2. Izin Akses Android (`android/app/src/main/AndroidManifest.xml`)
Tambahkan baris berikut di luar tag <application> untuk meminta izin akses kamera dan izin memunculkan notifikasi (wajib untuk Android 13/API 33 ke atas).

```xml
<manifest xmlns:android="[http://schemas.android.com/apk/res/android](http://schemas.android.com/apk/res/android)">
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <application>
        ...
    </application>
</manifest>
```

### 3. Konfigurasi Desugaring (`android/app/build.gradle.kts`)
Plugin notifikasi lokal seringkali membutuhkan fitur Java 8+. Jika menargetkan perangkat Android lama, aktifkan core library desugaring.

```kts
android {
    ...
    compileOptions {
        // Aktifkan desugaring
        isCoreLibraryDesugaringEnabled = true
        ...
    }
}

dependencies {
    // Tambahkan dependensi desugar
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4") 
}
```

Nama : Widari Dwi Hayati
NIM : 2311102060