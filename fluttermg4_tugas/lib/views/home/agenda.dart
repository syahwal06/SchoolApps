import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgendaScreen extends StatefulWidget {
  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  CalendarFormat _calendarFormat =
      CalendarFormat.month; // Set default format to month
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _agendaList = [];
  List<dynamic> _filteredAgendaList = [];
  TextEditingController _searchController = TextEditingController();

  Future<List<dynamic>> fetchAgenda() async {
    final response = await http
        .get(Uri.parse('https://hayy.my.id/API_PHP_SMTR5/agenda.php'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load agenda data');
    }
  }

  Future<void> addAgenda(String judul, String isi, DateTime tgl, String status,
      String petugas) async {
    final response = await http.post(
      Uri.parse('https://hayy.my.id/API_PHP_SMTR5/agenda.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'judul_agenda': judul,
        'isi_agenda': isi,
        'tgl_agenda': tgl.toIso8601String(),
        'status_agenda': status,
        'kd_petugas': petugas,
        'tgl_post_agenda': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _agendaList.add({
          'judul_agenda': judul,
          'isi_agenda': isi,
          'tgl_agenda': tgl.toIso8601String(),
          'status_agenda': status,
          'kd_petugas': petugas,
          'tgl_post_agenda': DateTime.now().toIso8601String(),
        });
        _filteredAgendaList = _agendaList;
      });
    } else {
      throw Exception('Failed to add agenda');
    }
  }

  Future<void> editAgenda(String id, String judul, String isi, DateTime tgl,
      String status, String petugas) async {
    final response = await http.put(
      Uri.parse('https://hayy.my.id/API_PHP_SMTR5/agenda.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'kd_agenda': id,
        'judul_agenda': judul,
        'isi_agenda': isi,
        'tgl_agenda': tgl.toIso8601String(),
        'status_agenda': status,
        'kd_petugas': petugas,
        'tgl_post_agenda': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit agenda');
    }
  }
  Future<void> deleteAgenda(String id) async {
    final response = await http.delete(
      Uri.parse('https://hayy.my.id/API_PHP_SMTR5/agenda.php?kd_agenda=$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // Berhasil menghapus agenda
      setState(() {
        _agendaList.removeWhere((agenda) => agenda['kd_agenda'] == id);
        _filteredAgendaList.removeWhere((agenda) => agenda['kd_agenda'] == id);
      });
    } else {
      throw Exception('Gagal menghapus agenda');
    }
  }

  void _filterAgendaByDate(DateTime selectedDate) async {
    List<dynamic> allAgenda = await fetchAgenda();
    setState(() {
      _agendaList = allAgenda.where((agenda) {
        DateTime agendaDate = DateTime.parse(agenda['tgl_agenda']);
        return isSameDay(agendaDate, selectedDate);
      }).toList();
      _filteredAgendaList = _agendaList;
    });
  }

  void _filterAgendaByQuery(String query) {
    setState(() {
      _filteredAgendaList = _agendaList.where((agenda) {
        return (agenda['judul_agenda'] ?? '')
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            (agenda['isi_agenda'] ?? '')
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAgenda().then((data) {
      setState(() {
        _agendaList = data;
        _filteredAgendaList = data;
      });
    });
    _searchController.addListener(() {
      _filterAgendaByQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TambahAgendaScreen(addAgenda: addAgenda)),
                ).then((_) {
                  setState(() {});
                });
              },
            ),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // update `_focusedDay` here as well
                _calendarFormat = CalendarFormat
                    .month; // Ubah format kalender menjadi bulan saat hari dipilih
              });
              _filterAgendaByDate(selectedDay);
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredAgendaList.length,
              itemBuilder: (context, index) {
                var data = _filteredAgendaList[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['judul_agenda'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          data['isi_agenda'] ?? '',
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                        ),
                        SizedBox(height: 8),
                        Divider(color: Colors.grey[300]),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date: ${data['tgl_agenda'] ?? ''}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                            Text(
                              'Posted: ${data['tgl_post_agenda'] ?? ''}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status: ${data['status_agenda'] ?? ''}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                            Text(
                              'Officer: ${data['kd_petugas'] ?? ''}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blueAccent),
                              padding: EdgeInsets.all(8),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditAgendaScreen(
                                      editAgenda: editAgenda,
                                      data: data,
                                    ),
                                  ),
                                ).then((_) {
                                  setState(() {});
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              padding: EdgeInsets.all(8),
                              onPressed: () async {
                                bool? confirmDelete = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Konfirmasi'),
                                      content: Text(
                                          'Apakah Anda yakin ingin menghapus agenda ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: Text('Tidak'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Text('Ya'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmDelete == true) {
                                  await deleteAgenda(data['kd_agenda']);
                                  setState(() {
                                    _filteredAgendaList.removeAt(index);
                                  });
                                }
                              },
                            ),
                          ],
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
    );
  }
}

class TambahAgendaScreen extends StatefulWidget {
  final Future<void> Function(String, String, DateTime, String, String)
      addAgenda;

  TambahAgendaScreen({required this.addAgenda});

  @override
  _TambahAgendaScreenState createState() => _TambahAgendaScreenState();
}

class _TambahAgendaScreenState extends State<TambahAgendaScreen> {
  final TextEditingController judulController = TextEditingController();
  final TextEditingController isiController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController petugasController = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Agenda'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: judulController,
                decoration: InputDecoration(
                  labelText: 'Agenda Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: isiController,
                decoration: InputDecoration(
                  labelText: 'Agenda Content',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: statusController,
                decoration: InputDecoration(
                  labelText: 'Agenda Status',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: petugasController,
                decoration: InputDecoration(
                  labelText: 'Officer',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text(selectedDate == null
                    ? 'Select Agenda Date'
                    : 'Agenda Date: ${selectedDate!.toLocal()}'.split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (selectedDate != null) {
                    await widget.addAgenda(
                      judulController.text,
                      isiController.text,
                      selectedDate!,
                      statusController.text,
                      petugasController.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Agenda added successfully')));
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a date')));
                  }
                },
                child: Text('Add Agenda'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditAgendaScreen extends StatefulWidget {
  final Future<void> Function(String, String, String, DateTime, String, String)
      editAgenda;
  final Map<String, dynamic> data;

  EditAgendaScreen({required this.editAgenda, required this.data});

  @override
  _EditAgendaScreenState createState() => _EditAgendaScreenState();
}

class _EditAgendaScreenState extends State<EditAgendaScreen> {
  final TextEditingController judulController = TextEditingController();
  final TextEditingController isiController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController petugasController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    judulController.text = widget.data['judul_agenda'] ?? '';
    isiController.text = widget.data['isi_agenda'] ?? '';
    statusController.text = widget.data['status_agenda'] ?? '';
    petugasController.text = widget.data['kd_petugas'] ?? '';
    selectedDate = widget.data['tgl_agenda'] != null
        ? DateTime.parse(widget.data['tgl_agenda'])
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Agenda'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: judulController,
                decoration: InputDecoration(
                  labelText: 'Agenda Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: isiController,
                decoration: InputDecoration(
                  labelText: 'Agenda Content',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: statusController,
                decoration: InputDecoration(
                  labelText: 'Agenda Status',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: petugasController,
                decoration: InputDecoration(
                  labelText: 'Officer',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text(selectedDate == null
                    ? 'Select Agenda Date'
                    : 'Agenda Date: ${selectedDate!.toLocal()}'.split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (selectedDate != null) {
                    await widget.editAgenda(
                      widget.data['kd_agenda'] ?? '',
                      judulController.text,
                      isiController.text,
                      selectedDate!,
                      statusController.text,
                      petugasController.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Agenda edited successfully')));
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a date')));
                  }
                },
                child: Text('Edit Agenda'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
