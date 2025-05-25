import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  // ... (existing code)
}

class _LoginPageState extends State<LoginPage> {
  // ... (existing code)

  void _handleLogin() {
    // ... (existing code)

    if (email.isNotEmpty && password.isNotEmpty) {
      // ... (existing code)

      if (isNewUser) {
        // ... (existing code)
      } else {
        // Detaylı profil oluşturma sayfasına yönlendir
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/profile',
          (route) => false,
          arguments: email,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (existing code)
  }
} 