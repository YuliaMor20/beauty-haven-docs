import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'PaymentPage.dart';
import 'models/cartItem.dart';
import 'dart:io';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late Future<List<CartItem>> _cartItems;
  late Future<double> _cartTotal;

  @override
  void initState() {
    super.initState();
    _refreshCart();
  }

  void _refreshCart() {
    setState(() {
      _cartItems = _databaseHelper.getCartItems();
      _cartTotal = _databaseHelper.getCartTotal();
    });
  }

  void _removeCartItem(int? id) async {
    if (id == null) return; // Проверяем, что id не равен null
    await _databaseHelper.removeCartItem(id);
    _refreshCart();
  }

  void _clearCart() async {
    await _databaseHelper.clearCart();
    _refreshCart();
  }

  Future<void> _goToPayment(double total) async {
    final cartItems = await _databaseHelper.getCartItems();
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Корзина пуста!')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: пользователь не найден. Пожалуйста, войдите.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentFormPage(
          totalAmount: total,
          onPaymentSuccess: _clearCart,
          userId: userId,
          cartItems: cartItems.map((item) => item.toMap()).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1BFBE),
        title: const Text('Корзина'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearCart,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<CartItem>>(
              future: _cartItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Корзина пуста'));
                } else {
                  final cartItems = snapshot.data!;
                  return ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
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
                              item.photo.isNotEmpty
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(item.photo),
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
                                item.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Стоимость: ${item.price} руб.',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                                        onPressed: () {
                                          if (item.quantity > 1) {
                                            _databaseHelper.updateCartItemQuantity(
                                                item.id!, item.quantity - 1);
                                            _refreshCart();
                                          } else {
                                            _removeCartItem(item.id);
                                          }
                                        },
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle, color: Colors.green),
                                        onPressed: () {
                                          _databaseHelper.updateCartItemQuantity(
                                              item.id!, item.quantity + 1);
                                          _refreshCart();
                                        },
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _removeCartItem(item.id);
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
          ),
          FutureBuilder<double>(
            future: _cartTotal,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              } else {
                final total = snapshot.data ?? 0.0;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Итоговая стоимость: ${total.toStringAsFixed(2)} руб.',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: total > 0 ? () => _goToPayment(total) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B1D27),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Перейти к оплате'),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
