import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../user/login_page.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final Color primaryColor = const Color(0xFFB10044);
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();

  bool _isSaving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
  }

  Future<void> _updateSecurity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User session expired. Please login again.')),
        );
      }
      return;
    }

    try {
      // Re-authenticate first
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email ?? '',
        password: _currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // Update Email if changed
      bool emailChanged = _emailController.text.trim() != user.email;
      if (emailChanged) {
        await user.verifyBeforeUpdateEmail(_emailController.text.trim());
      }

      // Update Password if provided
      bool passwordChanged = _passwordController.text.isNotEmpty;
      if (passwordChanged) {
        await user.updatePassword(_passwordController.text);
      }

      // Also update email in Firestore admin doc if it exists
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'email': _emailController.text.trim(),
        'lastSecurityUpdate': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Expanded(child: Text('Credentials Updated')),
              ],
            ),
            content: Text(
              emailChanged 
                ? 'Your email and password have been updated. A verification link was sent to your new email. Please login again with your new credentials.'
                : 'Your security credentials have been updated successfully. Please login again to confirm.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
                child: Text('OK', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Update failed';
      if (e.code == 'wrong-password') message = 'Incorrect current password';
      else if (e.code == 'weak-password') message = 'New password is too weak';
      else if (e.code == 'requires-recent-login') message = 'Please logout and login again before changing security settings';
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Admin Credentials',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Update your login email and password. You will need to re-authenticate with your current password.',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
              const SizedBox(height: 32),
              
              _buildTextField(
                _emailController, 
                'Admin Email', 
                Icons.email_outlined, 
                'Enter new admin email',
                validator: (v) => v != null && !v.contains('@') ? 'Invalid email' : null,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                _passwordController, 
                'New Password', 
                Icons.lock_outline, 
                'Enter new password (optional)',
                obscure: _obscureNew,
                toggleObscure: () => setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                _confirmPasswordController, 
                'Confirm New Password', 
                Icons.lock_outline, 
                'Confirm your new password',
                obscure: _obscureConfirm,
                toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  if (_passwordController.text.isNotEmpty && v != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              
              const Text(
                'Confirm with Current Password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _currentPasswordController, 
                'Current Password', 
                Icons.security, 
                'Enter current password to save changes',
                obscure: _obscureCurrent,
                toggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (v) => v == null || v.isEmpty ? 'Required for verification' : null,
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _updateSecurity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save & Update credentials', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    String hint, {
    bool obscure = false, 
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon: toggleObscure != null 
            ? IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: toggleObscure)
            : null,
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      validator: validator,
    );
  }
}
