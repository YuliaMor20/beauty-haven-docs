import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'AddMasterPage.dart';
import 'dart:io';

class MastersPage extends StatefulWidget {
  const MastersPage({super.key});

  @override
  _MastersPageState createState() => _MastersPageState();
}

class _MastersPageState extends State<MastersPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _masters;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _masters = _loadMasters();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('role');
    });
  }

  Future<List<Map<String, dynamic>>> _loadMasters() async {
    return await _databaseHelper.getMasters();
  }

  void _addMaster() async {
    final database = await _databaseHelper.database;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMasterPage(database: database),
      ),
    ).then((_) {
      setState(() {
        _masters = _loadMasters();
      });
    });
  }

  void _deleteMaster(int id) async {
    await _databaseHelper.deleteMaster(id);
    setState(() {
      _masters = _loadMasters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1BFBE),
        title: const Text('Мастера'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _masters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Мастера не найдены'));
          } else {
            final masters = snapshot.data!;
            return ListView.builder(
              itemCount: masters.length,
              itemBuilder: (context, index) {
                final master = masters[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        master['photo'] != ''
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(master['photo']),
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person, size: 50),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          master['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Категория: ${master['category']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          'Рейтинг: ${master['rating']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Описание: ${master['description'] ?? 'Нет описания'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_userRole == 'admin')
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteMaster(master['id']);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: _userRole == 'admin'
          ? FloatingActionButton(
        onPressed: _addMaster,
        backgroundColor: const Color(0xFF5B1D27),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}