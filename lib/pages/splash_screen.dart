import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user/login_page.dart';
import 'user/user_home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    
    _controller.forward().then((value) {
      if (mounted) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand Logo (contains brand name and tagline)
                Image.asset(
                  'assets/images/logo.png',
                  height: 180,
                  errorBuilder: (context, error, stackTrace) => Column(
                    children: [
                      const Icon(Icons.shopping_bag, size: 80, color: Color(0xFFB10044)),
                      const SizedBox(height: 12),
                      const Text(
                        'SHOPIDOE',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB10044),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                // Loading Bar
                SizedBox(
                  width: 200,
                  height: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: _animation.value,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB10044)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Text(
                      'Secure Boutique Checkout',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: Colors.pink[100]),
                const SizedBox(width: 20),
                Icon(Icons.brush, color: Colors.pink[100]),
                const SizedBox(width: 20),
                Icon(Icons.shopping_bag_outlined, color: Colors.pink[100]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
