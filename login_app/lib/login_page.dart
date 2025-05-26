import 'package:flutter/material.dart';
import 'models/user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() {
    print('\n=== GİRİŞ BUTONU BASILDI ===');
    
    if (_formKey.currentState!.validate()) {
      print('Form validasyonu başarılı');
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text;
      final password = _passwordController.text;

      print('\n=== GİRİŞ DENEME BİLGİLERİ ===');
      print('Girilen e-posta: "$email"');
      print('Girilen şifre: "$password"');
      print('=== GİRİŞ DENEME BİLGİLERİ SONU ===\n');

      // Kullanıcı doğrulama
      if (UserRepository.validateUser(email, password)) {
        print('Giriş başarılı - Ana sayfaya yönlendiriliyor');
        // Başarılı giriş
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: email,
        );
      } else {
        print('Giriş başarısız - Hata mesajı gösteriliyor');
        // Başarısız giriş
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-posta veya şifre hatalı!'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      print('Form validasyonu başarısız');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Logo veya uygulama adı
              const Icon(
                Icons.agriculture,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                'Çiftçi-Alıcı Platformu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              // E-posta alanı
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  print('E-posta validasyonu: $value');
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
              // Şifre alanı
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  print('Şifre validasyonu: $value');
                  if (value == null || value.isEmpty) {
                    return 'Şifre gereklidir';
                  }
                  if (value.length < 6) {
                    return 'Şifre en az 6 karakter olmalıdır';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Giriş yap butonu
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    print('Giriş butonu tıklandı');
                    _handleLogin();
                  },
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Giriş Yap',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Kayıt ol butonu
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
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