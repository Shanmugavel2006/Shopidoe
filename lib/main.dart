import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopidoe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB10044)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
