import 'package:flutter/material.dart';
import 'splash_screen.dart';
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF8B0000),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB22222),
          primary: const Color(0xFF8B0000),
          secondary: const Color(0xFFFF4500),
          background: const Color(0xFFF5F5F5),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onBackground: Colors.black,
          onSurface: Colors.black,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
