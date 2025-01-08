import 'package:flutter/material.dart';
import 'database_helper.dart';

class UserBookingsPage extends StatefulWidget {
  final int userId;

  const UserBookingsPage({super.key, required this.userId});

  @override
  _UserBookingsPageState createState() => _UserBookingsPageState();
}

class _UserBookingsPageState extends State<UserBookingsPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _userBookings;

  @override
  void initState() {
    super.initState();
    _userBookings = _loadUserBookings();
  }

  Future<List<Map<String, dynamic>>> _loadUserBookings() async {
    return await _databaseHelper.getUserBookings(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1BFBE),
        title: const Text('Мои записи'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _userBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет записей.'));
          } else {
            final bookings = snapshot.data!;
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Услуга: ${booking['service']}'),
                    subtitle: Text(
                      'Мастер: ${booking['master']}\nДата: ${booking['date']} Время: ${booking['time']}',
                    ),
                    trailing: Text('Телефон: ${booking['phone']}'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
