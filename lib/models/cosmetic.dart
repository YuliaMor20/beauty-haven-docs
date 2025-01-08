class Cosmetic {
  final int? id; // ID теперь nullable
  final String name;
  final double price;
  final String photo;

  Cosmetic({
    this.id, // ID необязателен
    required this.name,
    required this.price,
    required this.photo,
  });

  // Преобразование из Map
  factory Cosmetic.fromMap(Map<String, dynamic> map) {
    return Cosmetic(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      photo: map['photo'] as String,
    );
  }

  // Преобразование в Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'photo': photo,
    }..removeWhere((key, value) => value == null); // Удаление null-значений
  }
}
