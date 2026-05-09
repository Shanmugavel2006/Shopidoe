import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/splash_screen.dart';
import 'services/connectivity_service.dart';

// Global ValueNotifier to control the theme mode from anywhere in the app
// Global ValueNotifiers to control theme modes separately for User and Admin
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<ThemeMode> userThemeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<ThemeMode> adminThemeNotifier = ValueNotifier(ThemeMode.light);

// Global Key for ScaffoldMessenger to show SnackBars from anywhere
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize Connectivity Service
  ConnectivityService().initialize(scaffoldMessengerKey);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFB10044),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFFFF5F8),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFF5F8),
      elevation: 0,
      centerTitle: false,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFB10044),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
    ),
    cardColor: const Color(0xFF1E1E1E),
    dialogBackgroundColor: const Color(0xFF1E1E1E),
  );

  @override
  Widget build(BuildContext context) {
    // Check initial connection after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ConnectivityService().checkInitialConnection(scaffoldMessengerKey);
    });

    return MaterialApp(
      title: 'Shopidoe',
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light, // Default to light, but each portal will override
      home: const SplashScreen(),
    );
  }
}

class PortalTheme extends StatelessWidget {
  final ValueNotifier<ThemeMode> notifier;
  final Widget child;

  const PortalTheme({super.key, required this.notifier, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: notifier,
      builder: (context, mode, child) {
        return Theme(
          data: mode == ThemeMode.dark ? MyApp.darkTheme : MyApp.lightTheme,
          child: child!,
        );
      },
      child: child,
    );
  }
}

