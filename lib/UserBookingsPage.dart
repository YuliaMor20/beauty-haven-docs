import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'AddReviewPage.dart';
import 'package:intl/intl.dart';

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

  bool _isPastBooking(String date, String time) {
    final bookingDateTime = DateFormat('yyyy-MM-dd HH:mm').parse('$date $time');
    return bookingDateTime.isBefore(DateTime.now());
  }

  Future<bool> _hasReview(String serviceName, String date) async {
    return await _databaseHelper.hasReview(
      serviceName: serviceName,
      date: date,
      userId: widget.userId,
    );
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
                final isPast = _isPastBooking(booking['date'], booking['time']);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FutureBuilder<bool>(
                    future: _hasReview(booking['service'] as String, booking['date'] as String),
                    builder: (context, reviewSnapshot) {
                      final hasReview = reviewSnapshot.data ?? false;

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Услуга: ${booking['service']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('Мастер: ${booking['master']}'),
                            Text('Дата: ${booking['date']}'),
                            Text('Время: ${booking['time']}'),
                            const SizedBox(height: 8),
                            Text('Телефон: ${booking['phone']}'),
                            if (isPast && !hasReview)
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddReviewPage(
                                        masterName: booking['master'] as String,
                                        serviceName: booking['service'] as String,
                                        userId: widget.userId,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Оставить отзыв'),
                              ),
                          ],
                        ),
                      );
                    },
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
