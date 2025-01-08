import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'add_cosmetic_page.dart';
import 'dart:io';
import 'models/cosmetic.dart';
import 'models/cartItem.dart';

class CosmeticsPage extends StatefulWidget {
  const CosmeticsPage({super.key});

  @override
  _CosmeticsPageState createState() => _CosmeticsPageState();
}

class _CosmeticsPageState extends State<CosmeticsPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Future<List<Cosmetic>> _cosmetics;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _cosmetics = _loadCosmetics();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('role');
    });
  }

  Future<List<Cosmetic>> _loadCosmetics() async {
    return await _databaseHelper.getCosmetics();
  }

  Future<void> _addToCart(Cosmetic cosmetic) async {
    final cartItem = CartItem(
      id: null,
      name: cosmetic.name,
      price: cosmetic.price,
      photo: cosmetic.photo,
      quantity: 1,
    );

    await _databaseHelper.addToCart(cartItem);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Товар добавлен в корзину!')),
    );
  }

  void _addCosmetic() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCosmeticPage()),
    ).then((_) {
      setState(() {
        _cosmetics = _loadCosmetics();
      });
    });
  }

  void _deleteCosmetic(int? id) async {
    if (id == null) return; // Обработка случая, если ID отсутствует
    await _databaseHelper.deleteCosmetic(id);
    setState(() {
      _cosmetics = _loadCosmetics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1BFBE),
        title: const Text('Косметика'),
      ),
      body: FutureBuilder<List<Cosmetic>>(
        future: _cosmetics,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Косметика не найдена'));
          } else {
            final cosmetics = snapshot.data!;
            return ListView.builder(
              itemCount: cosmetics.length,
              itemBuilder: (context, index) {
                final cosmetic = cosmetics[index];
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
                        cosmetic.photo.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(cosmetic.photo),
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
                          cosmetic.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Стоимость: ${cosmetic.price} руб.',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _addToCart(cosmetic);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5B1D27),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('В корзину'),
                            ),
                            if (_userRole == 'admin')
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteCosmetic(cosmetic.id);
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
        onPressed: _addCosmetic,
        backgroundColor: const Color(0xFF5B1D27),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
