import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MastersPage.dart';
import 'ServicesPage.dart';
import 'CosmeticsPage.dart';
import 'CartPage.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'admin_panel.dart';
import 'database_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Очистка для тестирования

  runApp(const BeautyHavenApp());
}

class BeautyHavenApp extends StatelessWidget {
  const BeautyHavenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beauty Haven',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.zillaSlab(
            fontSize: 24,
            fontWeight: FontWeight.w500, // Менее жирный шрифт
          ),
          titleLarge: GoogleFonts.zillaSlab(
            fontSize: 20,
            fontWeight: FontWeight.w500, // Менее жирный шрифт
          ),
          bodyLarge: GoogleFonts.openSans(
            fontSize: 16,
            color: Colors.grey[800],
          ),
          bodyMedium: GoogleFonts.openSans(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ru', 'RU'),
      ],
      locale: const Locale('ru', 'RU'),
      home: FutureBuilder<bool>(
        future: _isUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            return const MainScreen();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }

  Future<bool> _isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String? _userRole;

  final List<Widget> _pages = const [
    HomePage(),
    MastersPage(),
    ServicesPage(),
    CosmeticsPage(),
    CartPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null) {
      final user = await DatabaseHelper().getUserById(userId);
      setState(() {
        _userRole = user?['role'];
      });
      if (user != null) {
        await prefs.setString('role', user['role']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1BFBE),
        title: Text(
          'Beauty Haven',
          style: GoogleFonts.zillaSlab(
            color: const Color(0xFF5B1D27),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_userRole == 'admin') ...[
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPanelPage()),
                );
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFFF1BFBE),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Мастера',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'Услуги',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Косметика',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Корзина',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Добро пожаловать!',
              textAlign: TextAlign.center, // Центрирование текста
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Наш салон предлагает широкий спектр услуг для ухода за собой. Мы заботимся о вашем стиле и красоте, предлагая лучшие услуги и качественную косметику.',
              textAlign: TextAlign.justify,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Наши услуги',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 1,
              mainAxisSpacing: 30,
              childAspectRatio: 2.0,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: const [
                MenuBlock(title: 'Уход за ногтями', imagePath: 'assets/services.jpg'),
                MenuBlock(title: 'Уход за волосами', imagePath: 'assets/cosmetics.jpg'),
                MenuBlock(title: 'Макияж', imagePath: 'assets/masters.jpg'),
              ],
            ),
            const SizedBox(height: 16),
            const ContactInfo(),
          ],
        ),
      ),
    );
  }
}

class MenuBlock extends StatelessWidget {
  final String title;
  final String imagePath;

  const MenuBlock({required this.title, required this.imagePath, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              title,
              style: GoogleFonts.zillaSlab(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w500, // Менее жирный шрифт
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactInfo extends StatelessWidget {
  const ContactInfo({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Контактная информация',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Адрес: г. Москва, ул. Красная, д. 12',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'Телефон: +7 (495) 123-45-67',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                onPressed: () => _launchUrl('https://wa.me/74951234567'),
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.telegram, color: Colors.blue),
                onPressed: () => _launchUrl('https://t.me/your_telegram_username'),
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.envelope, color: Colors.red),
                onPressed: () => _launchUrl('mailto:info@salon.ru'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
