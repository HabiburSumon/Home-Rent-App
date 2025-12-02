import 'package:flutter/material.dart';
import 'package:agentic_ai/app/features/authentication/presentation/pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Rent App',
      theme: ThemeData(
        primaryColor: const Color(0xFF4CAF50), // A vibrant green
        hintColor: const Color(0xFFFFA000), // An accent orange
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFA000),
        ),
        // Further customize other theme aspects
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(secondary: const Color(0xFFFFA000)),
      ),
      home: const SplashPage(),
    );
  }
}