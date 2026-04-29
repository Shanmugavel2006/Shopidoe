import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user/login_page.dart';

class AdminSettingsView extends StatefulWidget {
  const AdminSettingsView({super.key});

  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  final Color primaryColor = const Color(0xFFB10044);
  bool _isDarkMode = false;

  Widget _buildAvatar(String url, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isSelected ? primaryColor : Colors.transparent, width: 2),
      ),
      child: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(url),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title, String subtitle, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[300]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Store Settings',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 40),
          
          const Text('Profile Customization', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=12'),
                  backgroundColor: primaryColor.withOpacity(0.1),
                ),
                const SizedBox(height: 16),
                const Text('Select Default Avatar', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAvatar('https://i.pravatar.cc/150?img=12', isSelected: true),
                      _buildAvatar('https://i.pravatar.cc/150?img=13'),
                      _buildAvatar('https://i.pravatar.cc/150?img=14'),
                      _buildAvatar('https://i.pravatar.cc/150?img=15'),
                      _buildAvatar('https://i.pravatar.cc/150?img=16'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          const Text('App Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.wb_sunny_outlined, color: Colors.blue[700]),
                ),
                const SizedBox(width: 16),
                const Text('Dark Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Switch(
                  value: _isDarkMode,
                  onChanged: (v) => setState(() => _isDarkMode = v),
                  activeColor: primaryColor,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          _buildMenuOption(Icons.storefront_outlined, 'Store Information', 'Edit name, address, and contact', Colors.teal),
          _buildMenuOption(Icons.notifications_none_outlined, 'Notification Settings', 'Manage push and email alerts', Colors.blue),
          _buildMenuOption(Icons.payment_outlined, 'Payment Methods', 'Enable/disable payment options', Colors.green),
          _buildMenuOption(Icons.security_outlined, 'Security', 'Change password and admin permissions', Colors.blueGrey),
          _buildMenuOption(Icons.help_outline, 'Help & Support', 'Visit help center or contact us', Colors.orange),
          
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
