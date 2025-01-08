import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/AddServicePage.dart';
import 'dart:io';
import 'BookingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _services;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _services = _loadServices();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('role');
    });
  }

  Future<List<Map<String, dynamic>>> _loadServices() async {
    return await _databaseHelper.getServices();
  }

  void _addService() async {
    final database = await _databaseHelper.database;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddServicePage(database: database),
      ),
    ).then((_) {
      setState(() {
        _services = _loadServices();
      });
    });
  }

  void _deleteService(int id) async {
    await _databaseHelper.deleteService(id);
    setState(() {
      _services = _loadServices();
    });
  }

  void _bookService(Map<String, dynamic> service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPage(service: service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1BFBE),
        title: const Text('Услуги'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _services,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Услуги не найдены'));
          } else {
            final services = snapshot.data!;
            return ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
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
                        service['image'] != ''
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(service['image']),
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
                          child: const Icon(Icons.image, size: 50),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          service['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Стоимость: ${service['price']} руб.',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Длительность: ${service['duration']} мин',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => _bookService(service),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5B1D27), // Цвет фона кнопки
                                foregroundColor: Colors.white, // Цвет текста кнопки
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Записаться'),
                            ),
                            if (_userRole == 'admin')
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteService(service['id']);
                                },
                              ),
                          ],
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
        onPressed: _addService,
        backgroundColor: const Color(0xFF5B1D27),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
