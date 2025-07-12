import 'package:dtu_connect_2/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Light Theme (DTU maroon)
  static const Color _lightPrimary = Color(0xFF8B0000);
  static const Color _lightOnPrimary = Colors.white;
  static const Color _lightBackground = Colors.white;
  static const Color _lightSurface = Colors.white;
  static const Color _lightOnBackground = Colors.black;
  static const Color _lightOnSurface = Colors.black;
  static const Color _lightSecondary = Color(0xFF8B0000);
  static const Color _lightOnSecondary = Colors.white;

  // Dark Theme (Refined)
  static const Color _darkPrimary = Color(0xFF14B8A6); // Teal-500
  static const Color _darkBackground = Color(0xFF1E293B); // Slate-800
  static const Color _darkSurface = Color(0xFF273549); // Slate-700
  static const Color _darkOnPrimary = Color(0xFF0F172A); // Text on teal
  static const Color _darkOnBackground = Color(0xFFE2E8F0); // Gray-100
  static const Color _darkOnSurface = Color(0xFFE2E8F0);
  static const Color _darkSecondary = Color(0xFF2DD4BF); // Mint accent
  static const Color _darkOnSecondary = Color(0xFF0F172A);

  ThemeData get lightTheme {
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      secondary: _lightSecondary,
      onSecondary: _lightOnSecondary,
      background: _lightBackground,
      onBackground: _lightOnBackground,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      error: Colors.red,
      onError: Colors.white,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: _lightPrimary,
        foregroundColor: _lightOnPrimary,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(color: _lightPrimary),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightPrimary,
        selectedItemColor: _lightOnPrimary,
        unselectedItemColor: Colors.white70,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: _lightOnPrimary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _lightPrimary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightPrimary,
          side: const BorderSide(color: _lightPrimary),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: _lightOnBackground),
        titleMedium: TextStyle(color: _lightOnBackground),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  ThemeData get darkTheme {
    final colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      secondary: _darkSecondary,
      onSecondary: _darkOnSecondary,
      background: _darkBackground,
      onBackground: _darkOnBackground,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      error: Colors.redAccent,
      onError: Colors.white,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkPrimary,
        foregroundColor: _darkOnPrimary,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(color: _darkSecondary),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: _darkSecondary,
        unselectedItemColor: Colors.white54,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkSecondary,
          foregroundColor: _darkOnSecondary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _darkSecondary),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkSecondary,
          side: const BorderSide(color: _darkSecondary),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: _darkOnBackground),
        titleMedium: TextStyle(color: _darkOnBackground),
        labelLarge: TextStyle(color: _darkSecondary),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(),
        hintStyle: TextStyle(color: Colors.grey),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
