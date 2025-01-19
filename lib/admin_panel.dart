import 'package:flutter/material.dart';
import 'database_helper.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  _AdminPanelPageState createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _users;

  @override
  void initState() {
    super.initState();
    _users = _dbHelper.getUsers();
  }

  void _updateRole(int userId, String newRole) async {
    await _dbHelper.updateUserRole(userId, newRole);
    setState(() {
      _users = _dbHelper.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Админ-панель'),
        backgroundColor: const Color(0xFFF1BFBE),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Пользователи не найдены'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return ListTile(
                  title: Text(user['full_name']),
                  subtitle: Text('Роль: ${user['role']}'),
                  trailing: DropdownButton<String>(
                    value: user['role'],
                    items: ['admin', 'client', 'master'] // Добавлена роль мастер
                        .map((role) => DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    ))
                        .toList(),
                    onChanged: (newRole) {
                      if (newRole != null) {
                        _updateRole(user['id'], newRole);
                      }
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
