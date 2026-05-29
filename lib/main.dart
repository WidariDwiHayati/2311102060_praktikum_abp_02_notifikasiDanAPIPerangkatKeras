import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color purple = Color(0xFF9575CD); 
  static const Color green = Color(0xFF81C784);  
  static const Color lightPurpleBg = Color(0xFFF3E5F5); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Foto & Notifikasi',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          primary: purple,
          secondary: green,
          surface: lightPurpleBg,
        ),
        scaffoldBackgroundColor: lightPurpleBg,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// Kelas state untuk [HomePage].
/// Mengelola logika pengambilan gambar via kamera/galeri serta memicu notifikasi lokal.
class _HomePageState extends State<HomePage> {
  /// Menyimpan file gambar yang dipilih oleh pengguna untuk ditampilkan di UI.
  File? _image;
  
  /// Instance dari [ImagePicker] yang digunakan untuk mengakses kamera dan galeri perangkat.
  final ImagePicker _picker = ImagePicker();
  
  /// Instance dari plugin notifikasi lokal untuk menginisialisasi dan menampilkan notifikasi.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    // Memanggil fungsi inisialisasi notifikasi saat halaman pertama kali dimuat.
    _initializeNotifications();
  }

  /// Menginisialisasi pengaturan untuk notifikasi lokal.
  /// Fungsi ini mengatur ikon default notifikasi untuk platform Android.
  void _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Mengatur ikon yang akan muncul di status bar Android. 
    // '@mipmap/ic_launcher' menggunakan ikon default aplikasi.
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Menggabungkan pengaturan platform (dalam hal ini hanya Android).
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Mengeksekusi inisialisasi pada plugin.
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Menampilkan notifikasi push lokal kepada pengguna.
  /// Biasanya dipanggil setelah suatu aksi berhasil (misal: sukses mengambil foto).
  Future<void> _showNotification() async {
    // Mendefinisikan pengaturan spesifik untuk channel notifikasi Android.
    // Diperlukan untuk Android 8.0 (API level 26) ke atas.
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'foto_notifikasi_channel', // ID unik untuk channel notifikasi
      'Notifikasi Foto',         // Nama channel yang terlihat oleh pengguna di setting HP
      channelDescription: 'Notifikasi saat foto berhasil diambil',
      importance: Importance.max, // Tingkat kepentingan maksimal agar notifikasi pop-up (heads-up)
      priority: Priority.high,    // Prioritas tinggi
      showWhen: true,             // Menampilkan waktu (timestamp) notifikasi
      color: MyApp.purple,        // Warna aksen pada ikon notifikasi
    );

    // Membungkus pengaturan spesifik platform ke dalam objek detail notifikasi umum.
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Memicu notifikasi untuk muncul.
    // Parameter: ID notifikasi (0), Judul, Isi Pesan, dan Pengaturan Channel.
    await flutterLocalNotificationsPlugin.show(
      0, 
      'Sukses!', 
      'Foto cantikmu berhasil dimuat', 
      platformChannelSpecifics,
    );
  }

  /// Mengambil gambar berdasarkan sumber yang diberikan [source].
  /// Bisa menggunakan [ImageSource.camera] untuk mengambil foto langsung, 
  /// atau [ImageSource.gallery] untuk memilih dari galeri.
  Future<void> _getImage(ImageSource source) async {
    try {
      // Membuka antarmuka kamera atau galeri dan menunggu input pengguna.
      final XFile? pickedFile = await _picker.pickImage(source: source);

      // Jika pengguna memilih/mengambil gambar (tidak menekan tombol 'batal').
      if (pickedFile != null) {
        setState(() {
          // Memperbarui variabel state dengan path file gambar yang baru, 
          // sehingga UI akan dirender ulang untuk menampilkan gambar.
          _image = File(pickedFile.path);
        });
        
        // Memanggil fungsi notifikasi setelah gambar dipastikan berhasil dimuat.
        await _showNotification();
      }
    } catch (e) {
      // Menangkap error (seperti masalah izin akses) dan mencetaknya di konsol.
      debugPrint("Terjadi kesalahan saat mengambil gambar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kamera & Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [MyApp.purple, MyApp.green], 
            ),
          ),
        ),
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25), 
                  border: Border.all(color: MyApp.purple.withValues(alpha: 0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: MyApp.purple.withValues(alpha: 0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                // Menampilkan gambar jika `_image` tidak null, jika null tampilkan ikon default.
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(23), 
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_search, size: 50, color: MyApp.purple),
                            SizedBox(height: 10),
                            Text(
                              'Belum ada foto nih ka..',
                              style: TextStyle(color: MyApp.purple, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tombol untuk memicu _getImage dengan sumber kamera
                  ElevatedButton.icon(
                    onPressed: () => _getImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text('Kamera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyApp.purple,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Tombol untuk memicu _getImage dengan sumber galeri
                  ElevatedButton.icon(
                    onPressed: () => _getImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    label: const Text('Galeri', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyApp.green,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20.0),
        color: Colors.white,
        child: const Text(
          '2311102060 Widari Dwi Hayati',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MyApp.purple,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}