import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';

class AddMasterPage extends StatefulWidget {
  final Database database;
  const AddMasterPage({required this.database, super.key});

  @override
  _AddMasterPageState createState() => _AddMasterPageState();
}

class _AddMasterPageState extends State<AddMasterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _experienceController = TextEditingController();
  final _ratingController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _photoPath;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = ['Маникюр', 'Волосы', 'Макияж', 'Брови'];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoPath = image.path;
      });
    }
  }

  Future<void> _addMaster() async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text;
      final category = _selectedCategory;
      final experience = int.tryParse(_experienceController.text) ?? 0;
      final rating = double.tryParse(_ratingController.text) ?? 0.0;
      final description = _descriptionController.text;

      if (_photoPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пожалуйста, выберите фото')),
        );
        return;
      }

      await widget.database.insert(
        'masters',
        {
          'name': name,
          'category': category,
          'experience': experience,
          'rating': rating,
          'description': description,
          'photo': _photoPath ?? '',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1BFBE),
        title: const Text('Добавить Мастера'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'ФИО'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите ФИО';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Категория'),
                  items: _categories
                      .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, выберите категорию';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _experienceController,
                  decoration: const InputDecoration(labelText: 'Стаж (лет)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите стаж';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ratingController,
                  decoration: const InputDecoration(labelText: 'Рейтинг'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите рейтинг';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Описание'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите описание';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Выберите фото'),
                ),
                const SizedBox(height: 16),
                if (_photoPath != null)
                  Image.file(
                    File(_photoPath!),
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addMaster,
                  child: const Text('Добавить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
