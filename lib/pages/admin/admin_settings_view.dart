import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../user/login_page.dart';
import '../../main.dart';
import '../../services/cloudinary_service.dart';
import 'settings/store_info_page.dart';
import 'settings/payment_methods_page.dart';
import 'settings/security_settings_page.dart';
import 'settings/notification_settings_page.dart';
import 'settings/help_support_page.dart';
import 'settings/admin_profile_edit_page.dart';

class AdminSettingsView extends StatefulWidget {
  const AdminSettingsView({super.key});

  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  final Color primaryColor = const Color(0xFFB10044);

  Future<void> _pickAndUploadAdminImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading image...')),
        );
      }

      final url = await CloudinaryService.uploadImage(File(pickedFile.path));
      if (url != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'profileImageUrl': url,
            'role': 'admin',
          }, SetOptions(merge: true));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile picture updated successfully!')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image.')),
          );
        }
      }
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Options',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.upload, color: primaryColor),
              title: const Text('Upload New Image', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadAdminImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: primaryColor),
              title: const Text('Edit Profile Details', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminProfileEditPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Store Settings',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 40),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profile Customization', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminProfileEditPage())),
                child: Text('Edit Profile', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (user != null)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data() as Map<String, dynamic>?;
                final imageUrl = data?['profileImageUrl'] ?? 'https://i.pravatar.cc/150?img=12';
                final adminName = data?['name'] ?? 'Admin User';
                
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showImageOptions,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: primaryColor.withOpacity(0.5), width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(imageUrl),
                                backgroundColor: primaryColor.withOpacity(0.1),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(adminName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(user.email ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                    ],
                  ),
                );
              }
            ),
          
          const SizedBox(height: 40),
          const Text('App Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.wb_sunny_outlined, color: Colors.blue[400]),
                ),
                const SizedBox(width: 16),
                const Text('Dark Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: adminThemeNotifier,
                  builder: (_, mode, __) {
                    return Switch(
                      value: mode == ThemeMode.dark,
                      onChanged: (v) {
                        adminThemeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                      },
                      activeColor: primaryColor,
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          _buildMenuOption(
            Icons.storefront_outlined, 
            'Store Information', 
            'Edit name, address, and contact', 
            Colors.teal,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StoreInfoPage())),
          ),
          _buildMenuOption(
            Icons.notifications_none_outlined, 
            'Notification Settings', 
            'Manage push and email alerts', 
            Colors.blue,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsPage())),
          ),
          _buildMenuOption(
            Icons.payment_outlined, 
            'Payment Methods', 
            'Enable/disable payment options', 
            Colors.green,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsPage())),
          ),
          _buildMenuOption(
            Icons.security_outlined, 
            'Security', 
            'Change password and email', 
            Colors.blueGrey,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecuritySettingsPage())),
          ),
          _buildMenuOption(
            Icons.help_outline, 
            'Help & Support', 
            'Visit help center or contact us', 
            Colors.orange,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportPage())),
          ),
          
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout from Admin', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[400],
                side: BorderSide(color: Colors.red[400]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

