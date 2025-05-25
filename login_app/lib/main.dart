import 'package:flutter/material.dart';
import 'register_page.dart';
import 'user_model.dart';
import 'pages/create_profile_page.dart';
import 'home_page.dart';
import 'pages/advert_detail_page.dart';
import 'pages/messages_page.dart';
import 'pages/favorites_page.dart';
import 'models/advertisement.dart';

void main() {
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      if (UserRepository.validateUser(email, password)) {
        // Başarılı giriş mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giriş başarılı!'),
            backgroundColor: Colors.green,
          ),
        );

        // Profil kontrolü yap ve yönlendir
        if (UserRepository.hasProfile(email)) {
          // Ana sayfaya yönlendir
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
            arguments: email,
          );
        } else {
          // Detaylı profil oluşturma sayfasına yönlendir
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => CreateProfilePage(userEmail: email),
            ),
            (route) => false,
          );
        }
      } else {
        // Hatalı giriş mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-posta veya şifre hatalı!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'E-posta adresi gereklidir';
                  }
                  if (!value.contains('@')) {
                    return 'Geçerli bir e-posta adresi giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Şifre gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Giriş Yap'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text('Hesabınız yok mu? Kayıt olun'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
