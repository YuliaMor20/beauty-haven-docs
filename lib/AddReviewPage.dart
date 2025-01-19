import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

class AddReviewPage extends StatefulWidget {
  final String masterName;
  final String serviceName;
  final int userId; // Добавляем userId

  const AddReviewPage({
    super.key,
    required this.masterName,
    required this.serviceName,
    required this.userId,
  });

  @override
  _AddReviewPageState createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  int? _rating;
  String? _comment;

  void _submitReview() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Получаем текущую дату
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await _databaseHelper.addReview(
        masterName: widget.masterName,
        serviceName: widget.serviceName,
        date: currentDate, // Передаем текущую дату
        userId: widget.userId, // Передаем userId
        rating: _rating!,
        comment: _comment,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Отзыв успешно добавлен!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить отзыв'),
        backgroundColor: const Color(0xFFF1BFBE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Мастер: ${widget.masterName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Услуга: ${widget.serviceName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Оценка',
                  labelStyle: const TextStyle(color: Colors.brown),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: List.generate(5, (index) => index + 1)
                    .map((rating) => DropdownMenuItem(
                  value: rating,
                  child: Text(rating.toString()),
                ))
                    .toList(),
                validator: (value) => value == null ? 'Пожалуйста, выберите оценку' : null,
                onChanged: (value) {
                  setState(() {
                    _rating = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Комментарий',
                  labelStyle: const TextStyle(color: Colors.brown),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                onSaved: (value) {
                  _comment = value;
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B1D27),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Отправить отзыв',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
