import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'login_page.dart';
import 'MyOrdersPage.dart'; // Страница с заказами
import 'UserBookingsPage.dart'; // Страница с записями

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваш профиль'),
        backgroundColor: const Color(0xFFF1BFBE),
      ),
      body: FutureBuilder(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Нет данных о пользователе.'));
          } else {
            final user = snapshot.data as Map<String, String>;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${user['id'] ?? "Не указано"}'),
                  Text('ФИО: ${user['full_name'] ?? "Не указано"}'),
                  Text('Номер телефона: ${user['phone'] ?? "Не указано"}'),
                  Text('Имя пользователя: ${user['username'] ?? "Не указано"}'),
                  Text('Электронная почта: ${user['email'] ?? "Не указано"}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text('Выйти'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyOrdersPage(userId: int.parse(user['id']!)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B1D27),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Мои заказы'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserBookingsPage(userId: int.parse(user['id']!)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B1D27),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Мои записи'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<Map<String, String>?> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      return null;
    }

    final db = DatabaseHelper();
    final user = await db.getUserById(userId);

    if (user != null) {
      return {
        'id': user['id'].toString(),
        'full_name': user['full_name'] ?? 'Не указано',
        'phone': user['phone'] ?? 'Не указано',
        'username': user['username'] ?? 'Не указано',
        'email': user['email'] ?? 'Не указано',
      };
    }
    return null;
  }
}
