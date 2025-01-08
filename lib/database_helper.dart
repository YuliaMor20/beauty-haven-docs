import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/cosmetic.dart';
import 'models/cartItem.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initializeDatabase();
      return _database!;
    }
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'beauty_haven.db');

    return await openDatabase(
      path,
      version: 10, // Увеличена версия для добавления нового столбца
      onCreate: (db, version) async {
        await _createUsersTable(db);
        await _createMastersTable(db);
        await _createServicesTable(db);
        await _createBookingsTable(db);
        await _createCosmeticsTable(db);
        await _createCartTable(db);
        await _createOrdersTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 10) {
          await _addCategoryToServicesTable(db);
        }
      },
    );
  }
  Future<void> _addCategoryToServicesTable(Database db) async {
    try {
      await db.execute("ALTER TABLE services ADD COLUMN category TEXT");
    } catch (e) {
      print('Error adding category column to services: $e');
    }
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'client'
      )
    ''');
  }


  Future<void> _addRoleToUsersTable(Database db) async {
    try {
      await db.execute("ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'client'");
    } catch (e) {
      print('Столбец role уже существует или ошибка: $e');
    }
  }

  Future<void> _createMastersTable(Database db) async {
    await db.execute('''
      CREATE TABLE masters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        experience INTEGER,
        rating REAL,
        description TEXT,
        photo TEXT
      )
    ''');
  }

  Future<void> _createServicesTable(Database db) async {
    await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT, -- Добавлено для фильтрации мастеров по категориям
        duration TEXT,
        price REAL,
        image TEXT
        ALTER TABLE services ADD COLUMN category TEXT;

      )
    ''');
  }

  Future<void> _createBookingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT,
        phone TEXT,
        service TEXT,
        master TEXT,
        date TEXT,
        time TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future<void> _createCosmeticsTable(Database db) async {
    await db.execute('''
      CREATE TABLE cosmetics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        photo TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createCartTable(Database db) async {
    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        photo TEXT NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _createOrdersTable(Database db) async {
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        items TEXT NOT NULL,
        total REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }


  // Методы для работы с таблицей users
  Future<int> registerUser(
      String username, String password, String fullName, String email, String phone,
      {String role = 'client'}) async {
    final db = await database;
    return await db.insert('users', {
      'username': username,
      'password': password,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
    });
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUserRole(int userId, String newRole) async {
    final db = await database;
    return await db.update(
      'users',
      {'role': newRole},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // Методы для работы с таблицей masters
  Future<List<Map<String, dynamic>>> getMasters() async {
    final db = await database;
    return await db.query('masters');
  }
  // Фильтрация мастеров по категории
  Future<List<Map<String, dynamic>>> getMastersByCategory(String category) async {
    final db = await database;
    return await db.query(
      'masters',
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  Future<int> insertMaster(Map<String, dynamic> master) async {
    final db = await database;
    return await db.insert('masters', master);
  }

  Future<int> deleteMaster(int id) async {
    final db = await database;
    return await db.delete(
      'masters',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Методы для работы с таблицей services
  Future<List<Map<String, dynamic>>> getServices() async {
    final db = await database;
    return await db.query('services');
  }

  Future<int> insertService(Map<String, dynamic> service) async {
    final db = await database;
    return await db.insert('services', service);
  }

  Future<int> deleteService(int id) async {
    final db = await database;
    return await db.delete(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getBookingsByDate(String date) async {
    final db = await database;
    return await db.query(
      'bookings',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<void> bookService(
      int userId, String service, String master, String date, String time, String phone) async {
    final db = await database;
    await db.insert('bookings', {
      'user_id': userId,
      'service': service,
      'master': master,
      'date': date,
      'time': time,
      'phone': phone,
    });
  }

  // Методы для работы с таблицей cosmetics
  Future<List<Cosmetic>> getCosmetics() async {
    final db = await database;
    final result = await db.query('cosmetics');
    return result.map((e) => Cosmetic.fromMap(e)).toList();
  }

  Future<int> addCosmetic(Cosmetic cosmetic) async {
    final db = await database;
    return await db.insert(
      'cosmetics',
      cosmetic.toMap()..remove('id'),
    );
  }

  Future<int> deleteCosmetic(int id) async {
    final db = await database;
    return await db.delete(
      'cosmetics',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Методы для работы с корзиной
  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final result = await db.query('cart');
    return result.map((e) => CartItem.fromMap(e)).toList();
  }

  Future<void> addToCart(CartItem cartItem) async {
    final db = await database;

    final existingItem = await db.query(
      'cart',
      where: 'name = ? AND price = ?',
      whereArgs: [cartItem.name, cartItem.price],
    );

    if (existingItem.isNotEmpty) {
      final existingId = existingItem.first['id'] as int;
      final currentQuantity = existingItem.first['quantity'] as int;
      await db.update(
        'cart',
        {'quantity': currentQuantity + cartItem.quantity},
        where: 'id = ?',
        whereArgs: [existingId],
      );
    } else {
      await db.insert('cart', cartItem.toMap());
    }
  }

  Future<int> updateCartItemQuantity(int id, int quantity) async {
    final db = await database;
    return await db.update(
      'cart',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> removeCartItem(int id) async {
    final db = await database;
    return await db.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }

  Future<double> getCartTotal() async {
    final db = await database;
    final cartItems = await db.query('cart');
    double total = 0.0;

    for (var item in cartItems) {
      total += (item['price'] as double) * (item['quantity'] as int);
    }

    return total;
  }

  Future<void> deleteDatabaseFile() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'beauty_haven.db');

    try {
      await deleteDatabase(path);
      print('Database deleted successfully');
    } catch (e) {
      print('Error deleting database: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserBookings(int userId) async {
    final db = await database;
    return await db.query(
      'bookings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getUserOrders(int userId) async {
    final db = await database;
    return await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> addOrder(int userId, List<Map<String, dynamic>> items, double total) async {
    final db = await database;
    final date = DateTime.now().toIso8601String();

    return await db.insert('orders', {
      'user_id': userId,
      'items': jsonEncode(items),
      'total': total,
      'date': date,
    });
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }
}