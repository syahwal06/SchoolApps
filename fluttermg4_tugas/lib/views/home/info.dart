import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class InfoScreen extends StatefulWidget {
  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  List<IconData> _icons = [
    Icons.notifications,
    Icons.star,
    Icons.mail,
    Icons.message,
    Icons.favorite,
    Icons.info,
    Icons.access_alarm,
    Icons.account_circle,
  ];

  List<dynamic> _allInfo = [];
  List<dynamic> _filteredInfo = [];
  bool _isSearching = false;
  Random random = Random();

  Future<void> fetchInfo() async {
    final response = await http.get(Uri.parse('https://hayy.my.id/API_PHP_SMTR5/informasi.php'));
    if (response.statusCode == 200) {
      setState(() {
        _allInfo = json.decode(response.body);
        _filteredInfo = _allInfo;
      });
    } else {
      throw Exception('Failed to load info');
    }
  }

  Future<void> addInfo(String judul, String isi, String status, String petugas) async {
    final response = await http.post(
      Uri.parse('https://hayy.my.id/API_PHP_SMTR5/informasi.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'judul_info': judul,
        'isi_info': isi,
        'tgl_post_info': DateTime.now().toIso8601String(),
        'status_info': status,
        'kd_petugas': petugas,
      }),
    );

    if (response.statusCode == 200) {
      fetchInfo();
    } else {
      throw Exception('Failed to add info');
    }
  }

  Future<void> editInfo(String id, String judul, String isi, String status, String petugas) async {
    final response = await http.put(
      Uri.parse('https://hayy.my.id/API_PHP_SMTR5/informasi.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'kd_info': id,
        'judul_info': judul,
        'isi_info': isi,
        'tgl_post_info': DateTime.now().toIso8601String(),
        'status_info': status,
        'kd_petugas': petugas,
      }),
    );

    if (response.statusCode == 200) {
      fetchInfo();
    } else {
      throw Exception('Failed to edit info');
    }
  }

  Future<void> deleteInfo(String id) async {
    final response = await http.delete(
      Uri.parse('https://hayy.my.id/API_PHP_SMTR5/informasi.php?kd_info=$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      fetchInfo();
    } else {
      throw Exception('Failed to delete info');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInfo();
  }

  void _filterInfo(String enteredKeyword) {
    setState(() {
      if (enteredKeyword.isEmpty) {
        _filteredInfo = _allInfo;
      } else {
        _filteredInfo = _allInfo
            .where((info) =>
                info['judul_info'].toLowerCase().contains(enteredKeyword.toLowerCase()) ||
                info['isi_info'].toLowerCase().contains(enteredKeyword.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                onChanged: (value) {
                  _filterInfo(value);
                },
                autofocus: true,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Cari Informasi...',
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                ),
              )
            : Text("", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.black),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _filteredInfo = _allInfo;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: () {
              _showAddInfoDialog(context);
            },
          ),
        ],
      ),
      body: _filteredInfo.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _filteredInfo.length,
              itemBuilder: (context, index) {
                var info = _filteredInfo[index];
                IconData selectedIcon = _icons[random.nextInt(_icons.length)];

                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        selectedIcon,
                        color: Colors.blueAccent,
                        size: 40,
                      ),
                    ),
                    title: Text(
                      info['judul_info'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(info['isi_info'] ?? '', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Tanggal: ${info['tgl_post_info'] ?? ''}', style: TextStyle(color: Colors.grey[600])),
                        Text('Status: ${info['status_info'] ?? ''}', style: TextStyle(color: Colors.grey[600])),
                        Text('Officer: ${info['kd_petugas'] ?? ''}', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    trailing: Wrap(
                      spacing: 12,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () {
                            _showEditInfoDialog(context, info);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            await deleteInfo(info['kd_info']);
                          },
                        ),
                      ],
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                );
              },
            ),
      backgroundColor: Colors.grey[100],
    );
  }

  void _showAddInfoDialog(BuildContext context) {
    String judul = '';
    String isi = '';
    String status = '';
    String petugas = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Informasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  judul = value;
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Isi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  isi = value;
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  status = value;
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Petugas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  petugas = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Tambah'),
              onPressed: () async {
                await addInfo(judul, isi, status, petugas);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditInfoDialog(BuildContext context, dynamic info) {
    TextEditingController judulController = TextEditingController(text: info['judul_info']);
    TextEditingController isiController = TextEditingController(text: info['isi_info']);
    TextEditingController statusController = TextEditingController(text: info['status_info']);
    TextEditingController petugasController = TextEditingController(text: info['kd_petugas']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Informasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulController,
                decoration: InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: isiController,
                decoration: InputDecoration(
                  labelText: 'Isi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: statusController,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: petugasController,
                decoration: InputDecoration(
                  labelText: 'Petugas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Simpan'),
              onPressed: () async {
                await editInfo(
                  info['kd_info'],
                  judulController.text,
                  isiController.text,
                  statusController.text,
                  petugasController.text,
                );
                Navigator.of(context).pop();
                setState(() {
                  fetchInfo();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
