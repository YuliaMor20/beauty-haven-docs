

class Master {
  final int id;
  final String name;
  final int experience;
  final String position;  // Позиция мастера (была category)
  final String reviews;   // Отзывы о мастере (не rating)
  final String? photo;    // Фото мастера (может быть null)

  Master({
    required this.id,
    required this.name,
    required this.experience,
    required this.position,
    required this.reviews,
    this.photo,
  });

  // Преобразование из Map в объект Master
  factory Master.fromMap(Map<String, dynamic> map) {
    return Master(
      id: map['id'],
      name: map['name'],
      experience: map['experience'],
      position: map['position'],  // Используем 'position' для категории
      reviews: map['reviews'],    // Используем 'reviews' для отзывов
      photo: map['photo'],       // Чтение фото
    );
  }

  // Преобразование объекта Master в Map для базы данных
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'experience': experience,
      'position': position,    // 'position' для категории
      'reviews': reviews,      // 'reviews' для отзывов
      'photo': photo,          // Добавляем поле фото
    };
  }

}