import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  HomeScreen({required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showWelcomeMessage = true;

  @override
  void initState() {
    super.initState();
    // Timer untuk menghilangkan pesan selamat datang setelah 3 detik
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _showWelcomeMessage = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan username tidak null
    String displayUsername = widget.username.isNotEmpty ? widget.username : 'User';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              if (_showWelcomeMessage)
                Text(
                  'Selamat Datang, $displayUsername',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              SizedBox(height: 20),
              _buildCarouselSlider(),
              SizedBox(height: 30),
              Text(
                'Menu Utama',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              SizedBox(height: 20),
              _buildIconGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 220.0,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        enlargeCenterPage: true,
      ),
      items: imgList.map((item) => Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: Offset(4, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.grey,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 50,
                      ),
                      SizedBox(height: 10),
                      Text('Gambar gagal dimuat', style: TextStyle(color: Colors.red)),
                                       ],
                  ),
                ),
              ),
            ),
          )).toList(),
    );
  }

  Widget _buildIconGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      children: [
        _buildIconCard(context, Icons.schedule, 'Jadwal Masuk', Colors.blue, JadwalMasukScreen()),
        _buildIconCard(context, Icons.check_circle, 'Absensi', Colors.green, AbsensiScreen()),
        _buildIconCard(context, Icons.book, 'Matakuliah', Colors.orange, MatakuliahScreen()),
        _buildIconCard(context, Icons.grade, 'Nilai', Colors.red, NilaiScreen()),
      ],
    );
  }

  Widget _buildIconCard(BuildContext context, IconData icon, String label, Color color, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              SizedBox(height: 10),
              Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  final List<String> imgList = [
    'https://via.placeholder.com/600x400.png?text=Image+1',
    'https://via.placeholder.com/600x400.png?text=Image+2',
    'https://via.placeholder.com/600x400.png?text=Image+3',
    'https://via.placeholder.com/600x400.png?text=Image+4',
    'https://via.placeholder.com/600x400.png?text=Image+5',
  ];
}

// Halaman Jadwal Masuk
class JadwalMasukScreen extends StatelessWidget {
  final List<Map<String, String>> jadwal = [
    {"tanggal": "12 Oktober 2024", "waktu": "08:00 - 10:00", "mata kuliah": "Pemrograman Lanjut"},
    {"tanggal": "13 Oktober 2024", "waktu": "10:00 - 12:00", "mata kuliah": "Matematika Diskrit"},
    {"tanggal": "14 Oktober 2024", "waktu": "13:00 - 15:00", "mata kuliah": "Sistem Operasi"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal Masuk'),
      ),
      body: ListView.builder(
        itemCount: jadwal.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Icon(Icons.schedule, size: 40, color: Colors.blueAccent),
              title: Text(jadwal[index]['mata kuliah'] ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text('${jadwal[index]['tanggal']} | ${jadwal[index]['waktu']}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            ),
          );
        },
      ),
    );
  }
}

// Halaman Absensi
class AbsensiScreen extends StatelessWidget {
  final List<Map<String, String>> absensi = [
    {"tanggal": "12 Oktober 2024", "status": "Hadir"},
    {"tanggal": "13 Oktober 2024", "status": "Hadir"},
    {"tanggal": "14 Oktober 2024", "status": "Izin"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Absensi'),
      ),
      body: ListView.builder(
        itemCount: absensi.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Icon(
                absensi[index]['status'] == 'Hadir'
                    ? Icons.check_circle
                    : Icons.error_outline,
                size: 40,
                color: absensi[index]['status'] == 'Hadir' ? Colors.green : Colors.orange,
              ),
              title: Text('Tanggal: ${absensi[index]['tanggal']}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text('Status: ${absensi[index]['status']}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            ),
          );
        },
      ),
    );
  }
}

// Halaman Matakuliah
class MatakuliahScreen extends StatelessWidget {
  final List<String> matakuliah = [
    "Pemrograman Lanjut",
    "Matematika Diskrit",
    "Sistem Operasi",
    "Basis Data",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matakuliah'),
      ),
      body: ListView.builder(
        itemCount: matakuliah.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Icon(Icons.book, size: 40, color: Colors.orange),
              title: Text(matakuliah[index],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}

// Halaman Nilai
class NilaiScreen extends StatelessWidget {
  final List<Map<String, dynamic>> nilai = [
    {"mata kuliah": "Pemrograman Lanjut", "nilai": "A", "keterangan": "Sangat Baik"},
    {"mata kuliah": "Matematika Diskrit", "nilai": "B+", "keterangan": "Baik"},
    {"mata kuliah": "Sistem Operasi", "nilai": "A-", "keterangan": "Sangat Baik"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nilai'),
      ),
      body: ListView.builder(
        itemCount: nilai.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Icon(Icons.grade, size: 40, color: Colors.red),
              title: Text(nilai[index]['mata kuliah'] ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nilai: ${nilai[index]['nilai']}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  Text('Keterangan: ${nilai[index]['keterangan']}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
