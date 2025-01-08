class CartItem {
  final int? id; // Может быть null
  final String name;
  final double price;
  final String photo;
  final int quantity;

  CartItem({
    this.id, // Необязательный id
    required this.name,
    required this.price,
    required this.photo,
    required this.quantity,
  });

  // Создание объекта из Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as int?, // id может быть null
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      photo: map['photo'] as String,
      quantity: map['quantity'] as int,
    );
  }

  // Преобразование объекта в Map
  Map<String, dynamic> toMap() {
    return {
      'id': id, // id будет добавлен, если не равен null
      'name': name,
      'price': price,
      'photo': photo,
      'quantity': quantity,
    }..removeWhere((key, value) => value == null); // Удаляем null-значения
  }
}
