import 'package:flutter/material.dart';
import 'package:kasi_hustle/core/theme/app_theme.dart';
import 'package:kasi_hustle/features/auth/presentation/login_screen.dart';
import 'package:kasi_hustle/features/auth/presentation/login_screen_updated.dart';
import 'package:kasi_hustle/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kasi Hustle',
      theme: KasiTheme.lightTheme(),
      // darkTheme: KasiTheme.darkTheme(),
      // themeMode: ThemeMode.light,
      // themeMode: ThemeMode.system,
      // home: const MainLayout(),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
