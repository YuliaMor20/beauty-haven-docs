import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';
import 'models/cosmetic.dart';
import 'dart:io';

class AddCosmeticPage extends StatefulWidget {
  const AddCosmeticPage({super.key});

  @override
  _AddCosmeticPageState createState() => _AddCosmeticPageState();
}

class _AddCosmeticPageState extends State<AddCosmeticPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  File? _selectedImage;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _addCosmetic() async {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();

    if (name.isEmpty || priceText.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля и добавьте фото')),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректную стоимость')),
      );
      return;
    }

    // Создаем объект Cosmetic без id, чтобы база данных назначила его автоматически
    final cosmetic = Cosmetic(
      id: null, // ID будет автоматически назначен базой данных
      name: name,
      price: price,
      photo: _selectedImage!.path,
    );

    try {
      await _databaseHelper.addCosmetic(cosmetic);
      Navigator.pop(context); // Возвращаемся к предыдущей странице
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1BFBE),
        title: const Text('Добавить косметику'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImage!,
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
                child: const Icon(Icons.add_a_photo, size: 50),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название товара',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Стоимость',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addCosmetic,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B1D27),
              ),
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
