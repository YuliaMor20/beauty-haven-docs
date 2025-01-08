import 'package:flutter/material.dart';
import 'database_helper.dart';

class PaymentFormPage extends StatefulWidget {
  final double totalAmount;
  final VoidCallback onPaymentSuccess;
  final int userId;
  final List<Map<String, dynamic>> cartItems;

  const PaymentFormPage({
    super.key,
    required this.totalAmount,
    required this.onPaymentSuccess,
    required this.userId,
    required this.cartItems,
  });

  @override
  _PaymentFormPageState createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  void _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, исправьте ошибки в форме.')),
      );
      return;
    }

    try {
      await _databaseHelper.addOrder(
        widget.userId,
        widget.cartItems,
        widget.totalAmount,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Оплата успешно завершена!')),
      );

      widget.onPaymentSuccess();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении заказа: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1BFBE),
        title: const Text('Оплата'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Сумма к оплате: ${widget.totalAmount.toStringAsFixed(2)} руб.',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Номер карты',
                  hintText: '0000 0000 0000 0000',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите номер карты';
                  }
                  if (value.replaceAll(' ', '').length != 16) {
                    return 'Номер карты должен содержать 16 цифр';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expiryDateController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'Дата действия (MM/YY)',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите дату действия';
                  }
                  final parts = value.split('/');
                  if (parts.length != 2 ||
                      parts[0].length != 2 ||
                      parts[1].length != 2) {
                    return 'Введите дату в формате MM/YY';
                  }
                  final month = int.tryParse(parts[0]);
                  final year = int.tryParse(parts[1]);
                  if (month == null || year == null || month < 1 || month > 12) {
                    return 'Неверная дата';
                  }
                  final currentYear = DateTime.now().year % 100;
                  final currentMonth = DateTime.now().month;
                  if (year < currentYear || (year == currentYear && month < currentMonth)) {
                    return 'Срок действия истек';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: 'XXX',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите CVV';
                  }
                  if (value.length != 3) {
                    return 'CVV должен содержать 3 цифры';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Оплатить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
