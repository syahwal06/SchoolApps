import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GaleriScreen extends StatefulWidget {
  const GaleriScreen({super.key});

  @override
  _GaleriScreenState createState() => _GaleriScreenState();
}

class _GaleriScreenState extends State<GaleriScreen> {
  List<dynamic> _galeryData = [];
  List<dynamic> _filteredGaleryData = [];
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;

  @override
  void initState() {
    super.initState();
    fetchGalery();
  }

  Future<void> fetchGalery() async {
    final response = await http.get(
      Uri.parse('https://hayy.my.id/API-Refa/galeri.php'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (response.statusCode == 200) {
      setState(() {
        _galeryData = json.decode(utf8.decode(response.bodyBytes));
        _filteredGaleryData = _galeryData;
        if (_galeryData.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada data galeri')),
          );
        }
      });
    } else {
      throw Exception('Gagal memuat data galeri');
    }
  }

  void _filterGalery(String query) {
    setState(() {
      _filteredGaleryData = _galeryData
          .where((item) =>
              item['judul_galery'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> addGalery(
      String judul, String isi, String status, String kdPetugas) async {
    if (_image == null) {
      throw Exception('Gambar belum dipilih');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://hayy.my.id/API-Refa/galeri.php'),
    );

    request.fields['judul_galery'] = judul;
    request.fields['isi_galery'] = isi;
    request.fields['tgl_post_galery'] = DateTime.now().toIso8601String();
    request.fields['status_galery'] = status;
    request.fields['kd_petugas'] = kdPetugas;

    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      await fetchGalery();
    } else {
      throw Exception('Gagal menambahkan galeri');
    }
  }

  Future<void> editGalery(String id, String judul, String isi, String status,
      String kdPetugas) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://hayy.my.id/API-Refa/galeri.php'),
    );

    request.fields['kd_galery'] = id;
    request.fields['judul_galery'] = judul;
    request.fields['isi_galery'] = isi;
    request.fields['tgl_post_galery'] = DateTime.now().toIso8601String();
    request.fields['status_galery'] = status;
    request.fields['kd_petugas'] = kdPetugas;

    if (_image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      await fetchGalery();
    } else {
      throw Exception('Gagal mengedit galeri');
    }
  }

  Future<void> deleteGalery(String id) async {
    final response = await http.delete(
      Uri.parse('https://hayy.my.id/API-Refa/galeri.php?kd_galery=$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      await fetchGalery();
    } else {
      throw Exception('Gagal menghapus galeri');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari Galeri',
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.blueAccent),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.blueAccent),
                    onPressed: () {
                      _searchController.clear();
                      _filterGalery('');
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onChanged: _filterGalery,
              ),
            ),
            if (_filteredGaleryData.isNotEmpty)
              Container(
                height: 200,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Slider Galeri',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        itemCount: _filteredGaleryData.length,
                        itemBuilder: (context, index) {
                          var data = _filteredGaleryData[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: NetworkImage(
                                    'https://hayy.my.id/API-Refa/${data['image']}'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.5),
                                    Colors.transparent
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['judul_galery'] ?? 'Tidak ada judul',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      data['tgl_post_galery'] ??
                                          'Tidak ada tanggal',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Galeri',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      padding: const EdgeInsets.all(10.0),
                      itemCount: _filteredGaleryData.length,
                      itemBuilder: (context, index) {
                        var data = _filteredGaleryData[index];
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(data['judul_galery'] ??
                                      'Tidak ada judul'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.network(
                                        'https://hayy.my.id/API-Refa/${data['image']}',
                                        width: double.infinity,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: double.infinity,
                                            height: 150,
                                            color: Colors.grey[300],
                                            child: const Center(
                                                child: Text(
                                                    'Gambar tidak tersedia')),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      Text(data['isi_galery'] ??
                                          'Tidak ada deskripsi'),
                                      Text(data['tgl_post_galery'] ??
                                          'Tidak ada tanggal'),
                                      Text(data['status_galery'] ??
                                          'Tidak ada status'),
                                      Text(data['kd_petugas'] ??
                                          'Tidak ada kode petugas'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Tutup'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            final judulController =
                                                TextEditingController(
                                                    text: data['judul_galery']);
                                            final isiController =
                                                TextEditingController(
                                                    text: data['isi_galery']);
                                            final statusController =
                                                TextEditingController(
                                                    text:
                                                        data['status_galery']);
                                            final kdPetugasController =
                                                TextEditingController(
                                                    text:
                                                        data['kd_petugas']);

                                            return AlertDialog(
                                              title: const Text('Edit Galeri'),
                                              content: Column(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller:
                                                        judulController,
                                                    decoration:
                                                        const InputDecoration(
                                                            labelText:
                                                                'Judul'),
                                                  ),
                                                  TextField(
                                                    controller: isiController,
                                                    decoration:
                                                        const InputDecoration(
                                                            labelText: 'Isi'),
                                                  ),
                                                  Image.network(
                                                    'https://hayy.my.id/API-Refa/${data['image']}',
                                                    width: double.infinity,
                                                    height: 150,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        width: double.infinity,
                                                        height: 150,
                                                        color: Colors.grey[300],
                                                        child: const Center(
                                                            child: Text(
                                                                'Gambar tidak tersedia')),
                                                      );
                                                    },
                                                  ),
                                                  TextButton(
                                                    onPressed: _pickImage,
                                                    child: const Text(
                                                        'Pilih Gambar Baru'),
                                                  ),
                                                  if (_image != null)
                                                    Text(
                                                        'Gambar yang dipilih: ${_image!.path.split('/').last}'),
                                                  TextField(
                                                    controller:
                                                        statusController,
                                                    decoration:
                                                        const InputDecoration(
                                                            labelText:
                                                                'Status'),
                                                  ),
                                                  TextField(
                                                    controller:
                                                        kdPetugasController,
                                                    decoration:
                                                        const InputDecoration(
                                                            labelText:
                                                                'Kode Petugas'),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Batal'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    try {
                                                      await editGalery(
                                                        data['kd_galery'],
                                                        judulController.text,
                                                        isiController.text,
                                                        statusController.text,
                                                        kdPetugasController
                                                            .text,
                                                      );
                                                      Navigator.of(context)
                                                          .pop();
                                                    } catch (e) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'Error'),
                                                            content: Text(
                                                                'Gagal mengedit galeri: $e'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: const Text(
                                                                    'Tutup'),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                  child: const Text('Simpan'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Text('Edit'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          await deleteGalery(data['kd_galery']);
                                          Navigator.of(context).pop();
                                        } catch (e) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Error'),
                                                content: Text(
                                                    'Gagal menghapus galeri: $e'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Tutup'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15.0)),
                                    child: Image.network(
                                      'https://hayy.my.id/API-Refa/${data['image']}',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                              child: Text(
                                                  'Gambar tidak tersedia')),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    data['judul_galery'] ?? 'Tidak ada judul',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    data['tgl_post_galery'] ??
                                        'Tidak ada tanggal',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              final judulController = TextEditingController();
              final isiController = TextEditingController();
              final statusController = TextEditingController();
              final kdPetugasController = TextEditingController();

              return AlertDialog(
                title: const Text('Tambah Galeri'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: judulController,
                      decoration: const InputDecoration(labelText: 'Judul'),
                    ),
                    TextField(
                      controller: isiController,
                      decoration: const InputDecoration(labelText: 'Isi'),
                    ),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text('Pilih Gambar'),
                    ),
                    if (_image != null)
                      Text(
                          'Gambar yang dipilih: ${_image!.path.split('/').last}'),
                    TextField(
                      controller: statusController,
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    TextField(
                      controller: kdPetugasController,
                      decoration:
                          const InputDecoration(labelText: 'Kode Petugas'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await addGalery(
                        judulController.text,
                        isiController.text,
                        statusController.text,
                        kdPetugasController.text,
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}