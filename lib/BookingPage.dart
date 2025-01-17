import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingPage extends StatefulWidget {
  final Map<String, dynamic> service;

  const BookingPage({super.key, required this.service});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late List<Map<String, dynamic>> _masters;
  late List<String> _timeSlots;
  late List<String> _unavailableSlots;
  String? _selectedMaster;
  DateTime? _selectedDate;
  String? _selectedTime;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _masters = [];
    _unavailableSlots = [];
    _timeSlots = [];
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMasters();
    _loadUserData();
  }

  Future<void> _loadMasters() async {
    final category = widget.service['category'];
    final masters = await _databaseHelper.getMastersByCategory(category);
    setState(() {
      _masters = masters;
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final userName = prefs.getString('userName');
    final userPhone = prefs.getString('userPhone');

    if (userId != null) {
      setState(() {
        _userId = userId;
        _nameController.text = userName ?? '';
        _phoneController.text = userPhone ?? '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: невозможно определить пользователя.')),
      );
    }
  }

  List<String> _generateTimeSlots(String duration, DateTime selectedDate) {
    final List<String> slots = [];
    final serviceDuration = int.parse(duration);

    final now = DateTime.now();
    final startTime = TimeOfDay(hour: 10, minute: 0);
    final endTime = TimeOfDay(hour: 22, minute: 0);

    TimeOfDay current = startTime;

    while (current.hour < endTime.hour ||
        (current.hour == endTime.hour && current.minute < endTime.minute)) {
      final slotTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        current.hour,
        current.minute,
      );

      // Если выбранная дата совпадает с текущей, исключаем слоты до текущего времени
      if (selectedDate.year == now.year &&
          selectedDate.month == now.month &&
          selectedDate.day == now.day) {
        if (slotTime.isAfter(now)) {
          slots.add(current.format(context));
        }
      } else {
        // Для будущих дат добавляем все слоты
        slots.add(current.format(context));
      }

      final nextMinute = current.minute + serviceDuration;
      current = TimeOfDay(
        hour: current.hour + nextMinute ~/ 60,
        minute: nextMinute % 60,
      );
    }

    return slots;


}

  Future<void> _loadUnavailableSlots(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final bookings = await _databaseHelper.getBookingsByDate(formattedDate);

    setState(() {
      _unavailableSlots = bookings.map((b) => b['time'] as String).toList();
      _timeSlots = _generateTimeSlots(widget.service['duration'], date)
          .where((slot) => !_unavailableSlots.contains(slot))
          .toList();
    });
  }

  void _submitForm() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty ||
        phone.isEmpty ||
        _selectedMaster == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: невозможно определить пользователя. Пожалуйста, войдите снова.')),
      );
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    try {
      await _databaseHelper.bookService(
        _userId!,
        widget.service['name'],
        _selectedMaster!,
        formattedDate,
        _selectedTime!,
        phone,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запись успешно добавлена')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при добавлении записи')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1BFBE),
        title: const Text('Запись на услугу'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Услуга: ${widget.service['name']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'ФИО клиента'),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Номер телефона'),
            ),
            DropdownButton<String>(
              value: _selectedMaster,
              hint: const Text('Выберите мастера'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMaster = newValue;
                });
              },
              items: _masters.map((master) {
                return DropdownMenuItem<String>(
                  value: master['name'],
                  child: Text(master['name']),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (selectedDate != null) {
                  setState(() {
                    _selectedDate = selectedDate;
                  });
                  await _loadUnavailableSlots(selectedDate);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: const Color(0xFF5B1D27),
                foregroundColor: Colors.white,
              ),
              child: Text(_selectedDate == null
                  ? 'Выберите дату'
                  : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _timeSlots.map((slot) {
                final isUnavailable = _unavailableSlots.contains(slot);
                return ChoiceChip(
                  label: Text(slot),
                  selected: _selectedTime == slot,
                  onSelected: isUnavailable
                      ? null
                      : (bool selected) {
                    setState(() {
                      _selectedTime = selected ? slot : null;
                    });
                  },
                  selectedColor: const Color(0xFF5B1D27),
                  backgroundColor: isUnavailable ? Colors.grey : Colors.pink[50],
                  labelStyle: TextStyle(
                    color: isUnavailable
                        ? Colors.grey
                        : (_selectedTime == slot ? Colors.white : Colors.black),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: const Color(0xFF5B1D27),
                foregroundColor: Colors.white,
              ),
              child: const Text('Записаться'),
            ),
          ],
        ),
      ),
    );
  }
}
