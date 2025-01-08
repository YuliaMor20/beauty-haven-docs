import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'dart:convert'; // Для обработки JSON-строк

class MyOrdersPage extends StatefulWidget {
  final int userId;

  const MyOrdersPage({super.key, required this.userId});

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _userOrders;

  @override
  void initState() {
    super.initState();
    _userOrders = _loadUserOrders();
  }

  Future<List<Map<String, dynamic>>> _loadUserOrders() async {
    return await _databaseHelper.getUserOrders(widget.userId);
  }

  void _refreshOrders() {
    setState(() {
      _userOrders = _loadUserOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1BFBE),
        title: const Text('Мои заказы'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _userOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет заказов.'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final items = jsonDecode(order['items']) as List<dynamic>;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Дата: ${order['date']}'),
                    subtitle: Text(
                      'Итого: ${order['total']} руб.\nТовары: ${items.map((e) => e['name']).join(', ')}',
                    ),
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
