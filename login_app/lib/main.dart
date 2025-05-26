import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'models/user_model.dart';
import 'pages/create_profile_page.dart';
import 'home_page.dart';
import 'pages/advert_detail_page.dart';
import 'pages/messages_page.dart';
import 'pages/favorites_page.dart';
import 'models/advertisement.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserRepository.init(); // UserRepository'yi başlat
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Çiftçi-Alıcı Platformu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // Başlangıç sayfası olarak LoginPage'i göster
      home: const LoginPage(),
      // Route'ları tanımla
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            final String email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => HomePage(userEmail: email),
            );
          case '/profile':
            final String email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => CreateProfilePage(userEmail: email),
            );
          case '/register':
            return MaterialPageRoute(
              builder: (context) => const RegisterPage(),
            );
          case '/advert-detail':
            final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => AdvertDetailPage(
                advertisement: args['advertisement'] as Advertisement,
                currentUserEmail: args['userEmail'] as String,
              ),
            );
          case '/messages':
            final String email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => MessagesPage(userEmail: email),
            );
          case '/favorites':
            final String email = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => FavoritesPage(userEmail: email),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const LoginPage(),
            );
        }
      },
    );
  }
}
