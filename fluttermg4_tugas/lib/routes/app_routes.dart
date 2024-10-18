import 'package:flutter/material.dart';
import '../views/auth/login_page.dart';
import '../views/home/welcome_page.dart';

class AppRoutes {
  static const String login = '/';
  static const String welcome = '/welcome';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginScreen(),
    welcome: (context) => WelcomeScreen(username: ''), // Menambahkan argumen 'username' yang diperlukan
  };
}
