class Service {
  final int id;
  final String name;
  final String duration;  // Длительность услуги
  final double price;     // Стоимость услуги
  final String? category; // Категория услуги
  final String? image;    // Путь к изображению услуги

  Service({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    this.category,
    this.image,
  });

  // Преобразование из Map в объект Service
  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      name: map['name'],
      duration: map['duration'],
      price: map['price'],
      category: map['category'], // Чтение категории
      image: map['image'],       // Чтение пути к изображению
    );
  }

  // Преобразование объекта Service в Map для базы данных
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'price': price,
      'category': category, // Добавляем категорию
      'image': image ?? '', // Добавляем путь к изображению
    };
  }
}
