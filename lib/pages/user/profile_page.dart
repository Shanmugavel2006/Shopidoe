import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  final Color primaryColor = const Color(0xFFB10044);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(
            'assets/images/logo.png',
            errorBuilder: (context, error, stackTrace) => Icon(Icons.shopping_bag, color: primaryColor),
          ),
        ),
        title: Text(
          'SHOPIDOE',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout, color: Colors.grey),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile Header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
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
                  const SizedBox(height: 16),
                  const Text(
                    'Sarah Jenkins',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                  ),
                  const Text(
                    'sarah.j@example.com',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Present Orders
            _buildSectionHeader('Present Orders', 'TRACK ALL'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.image_outlined, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Velvet Rose Elixir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text('₹ 2,499.00', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('Oct 24, 2023 • 14:30 PM', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.pink[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('ON THE WAY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: primaryColor)),
                        ),
                        const SizedBox(height: 8),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            // Past Orders
            _buildSectionHeader('Past Orders', null),
            _buildPastOrderTile('Muted Stone Notebook', '₹ 899.00', 'Delivered • Sep 12 • 11:15 AM'),
            _buildPastOrderTile('Petal Blush Palette', '₹ 1,850.00', 'Delivered • Aug 28 • 09:45 AM'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey[200]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('View All History', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
            ),

            const SizedBox(height: 32),
            // Saved Addresses
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink[50]!.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Saved Addresses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('2 locations saved', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            // Account Settings
            _buildSectionHeader('Account Settings', null),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(Icons.notifications_none, 'Notifications', trailing: Switch(value: true, onChanged: (v){}, activeColor: primaryColor)),
                    _buildSettingsTile(Icons.help_outline, 'Help Center', showArrow: true),
                    _buildSettingsTile(Icons.info_outline, 'About Shopidoe', showArrow: true, isLast: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),
            Text(
              'SHOPIDOE V2.4.0 • CRAFTED WITH PASSION',
              style: TextStyle(fontSize: 10, color: Colors.grey[300], letterSpacing: 1),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? actionText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
          if (actionText != null)
            Text(actionText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildPastOrderTile(String name, String price, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.image_outlined, color: Colors.grey, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(price, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(status, textAlign: TextAlign.right, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, {Widget? trailing, bool showArrow = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey[50]!)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.black87),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: trailing ?? (showArrow ? const Icon(Icons.chevron_right, size: 20, color: Colors.grey) : null),
      ),
    );
  }
}
