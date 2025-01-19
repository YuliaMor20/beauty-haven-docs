import 'package:flutter/material.dart';
import 'database_helper.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _bookings;
  List<String> _masters = [];
  List<String> _dates = [];
  String? _selectedMaster;
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
    _bookings = _loadBookings();
  }

  Future<void> _initializeFilters() async {
    final masters = await _databaseHelper.getMasters();
    final bookings = await _databaseHelper.getBookings();

    setState(() {
      _masters = ['Все мастера', ...masters.map((master) => master['name'] as String).toList()];
      _dates = ['Все даты', ...bookings.map((booking) => booking['date'] as String).toSet().toList()];
    });
  }

  Future<List<Map<String, dynamic>>> _loadBookings() async {
    return await _databaseHelper.getBookings();
  }

  Future<List<Map<String, dynamic>>> _filterBookings() async {
    final allBookings = await _loadBookings();
    return allBookings.where((booking) {
      final matchesMaster = _selectedMaster == null || _selectedMaster == 'Все мастера' || booking['master'] == _selectedMaster;
      final matchesDate = _selectedDate == null || _selectedDate == 'Все даты' || booking['date'] == _selectedDate;
      return matchesMaster && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание'),
        backgroundColor: const Color(0xFFF1BFBE),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMaster,
                    decoration: const InputDecoration(
                      labelText: 'Мастер',
                      border: OutlineInputBorder(),
                    ),
                    items: _masters.map((master) {
                      return DropdownMenuItem(value: master, child: Text(master));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMaster = value;
                        _bookings = _filterBookings();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDate,
                    decoration: const InputDecoration(
                      labelText: 'Дата',
                      border: OutlineInputBorder(),
                    ),
                    items: _dates.map((date) {
                      return DropdownMenuItem(value: date, child: Text(date));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDate = value;
                        _bookings = _filterBookings();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _bookings,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка загрузки расписания: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Записей пока нет.',
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  );
                } else {
                  final bookings = snapshot.data!;
                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Мастер: ${booking['master']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Услуга: ${booking['service']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                'Клиент: ${booking['name']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Дата: ${booking['date']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    'Время: ${booking['time']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
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
          ),
        ],
      ),
    );
  }
}
