import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin/admin_login_page.dart';
import '../admin/admin_home_page.dart';
import 'signup_page.dart';
import 'user_home_page.dart';
import 'forgot_password_page.dart';

import '../../main.dart';

class LoginPage extends StatefulWidget {
  final bool showAccountDeletedPopup;
  const LoginPage({super.key, this.showAccountDeletedPopup = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _inputController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final Color primaryColor = const Color(0xFFB10044); // Magenta from image

  @override
  void initState() {
    super.initState();
    if (widget.showAccountDeletedPopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDeletedAccountDialog();
      });
    }
  }

  void _showDeletedAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: primaryColor),
            const SizedBox(width: 10),
            const Text('Account Deleted'),
          ],
        ),
        content: const Text('Your account has been deleted by the administrator. Please sign up again to continue using the store.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title, 
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('TRY AGAIN', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    String input = _inputController.text.trim();
    final password = _passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter mobile/email and password'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Dismiss keyboard for better UX
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    
    try {
      String email = input;
      DocumentSnapshot? userDocSnapshot;
      
      // Fast check: If it's a mobile number (doesn't contain @), find the email in Firestore
      if (!input.contains('@')) {
        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('mobile', isEqualTo: input)
            .limit(1)
            .get();
        
        if (userQuery.docs.isEmpty) {
          _showErrorDialog('Wrong Credentials', 'No user found with this mobile number. Please check your number or sign up.');
          setState(() => _isLoading = false);
          return;
        }
        userDocSnapshot = userQuery.docs.first;
        email = userDocSnapshot.get('email');
      }

      // Sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check isActive status in parallel or right after
      if (userDocSnapshot == null) {
        userDocSnapshot = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
      }

      if (userDocSnapshot.exists) {
        final userData = userDocSnapshot.data() as Map<String, dynamic>;
        if (userData['isActive'] == false) {
          await FirebaseAuth.instance.signOut();
          _showErrorDialog('Account Deactivated', 'Your account has been deactivated. Please contact admin.');
          setState(() => _isLoading = false);
          return;
        }

        // Check if the user is an admin and redirect to the appropriate portal
        if (userData['role'] == 'admin') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomePage()),
            );
          }
          return;
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String title = 'Login Failed';
      String message = e.message ?? 'An unexpected error occurred.';

      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        title = 'Wrong Credentials';
        message = 'The email/mobile or password you entered is incorrect. Please try again.';
      } else if (e.code == 'invalid-email') {
        title = 'Invalid Email';
        message = 'Please enter a valid email address.';
      } else if (e.code == 'too-many-requests') {
        title = 'Too Many Attempts';
        message = 'Login has been temporarily disabled due to too many failed attempts. Try again later.';
      } else if (e.code == 'network-request-failed') {
        title = 'Network Error';
        message = 'Please check your internet connection and try again.';
      }

      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog(title, message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Error', 'Something went wrong: $e');
      }
    } finally {
      // We don't set _isLoading = false here if we are navigating away
    }
  }

  @override
  Widget build(BuildContext context) {
    return PortalTheme(
      notifier: userThemeNotifier,
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 0),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    errorBuilder: (context, error, stackTrace) => Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [],
                          ),
                          child: const Icon(Icons.shopping_bag, size: 70, color: Color(0xFFB10044)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'SHOPIDOE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the details to login',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Mobile Number or Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mobile Number or Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _inputController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'number or email',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          'Forgot?',
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: '........',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: primaryColor,
                        ),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupPage()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Admin Sign-In Button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminLoginPage()),
                  );
                },
                icon: Icon(Icons.admin_panel_settings_outlined, size: 20, color: primaryColor),
                label: Text('Admin Sign-In', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ),
          );
        },
      ),
    );
  }
}
