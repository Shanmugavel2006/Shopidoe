import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user/login_page.dart';

class AdminUserProfileView extends StatefulWidget {
  final String userName;
  final String userPhone;
  final String userAddress;
  final String userEmail;

  const AdminUserProfileView({
    super.key,
    required this.userName,
    required this.userPhone,
    required this.userAddress,
    this.userEmail = 'user@example.com',
  });

  @override
  State<AdminUserProfileView> createState() => _AdminUserProfileViewState();
}

class _AdminUserProfileViewState extends State<AdminUserProfileView> {
  final Color primaryColor = const Color(0xFFB10044);
  final Color lightBgColor = const Color(0xFFFFF0F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF5F8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: primaryColor),
        ),
        title: Text(
          'User Profile',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings, color: primaryColor),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: lightBgColor,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF66BB6A), width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=68'),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1B4332),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.info_outline, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.userName,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.email_outlined, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          widget.userEmail,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone_outlined, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          widget.userPhone,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Order Status Section
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Order Status', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('#FaSybNA1', style: TextStyle(color: Colors.grey[300], fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildStatusRow('Ordered', true),
                  _buildStatusRow('Order Confirmed', false),
                  _buildStatusRow('Delivered', false),
                ],
              ),
            ),

            const SizedBox(height: 20),
            
            // Present Orders Section
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Present Orders', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA7FFEB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('2 ACTIVE', style: TextStyle(color: Color(0xFF1B4332), fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Order #FaSybNA1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('₹1316.00', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('29 Apr, 06:20 PM', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: Container(height: 6, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(3)))),
                            const SizedBox(width: 8),
                            Expanded(child: Container(height: 6, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(3)))),
                            const SizedBox(width: 8),
                            Expanded(child: Container(height: 6, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(3)))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('IN PREPARATION', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Past History Section
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Past History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('VIEW ALL', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(Icons.history, color: primaryColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Order #1y3zJajS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('28 Apr, 2026', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                            ],
                          ),
                        ),
                        Text('₹105.00', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Saved Addresses Section
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Saved Addresses', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('Edit / Add', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(color: Color(0xFF1B4332), shape: BoxShape.circle),
                          child: const Icon(Icons.home, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(widget.userAddress, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Admin Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Deactivate User', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Message User', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFFB10044).withOpacity(0.1)),
      ),
      child: child,
    );
  }

  Widget _buildStatusRow(String label, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isChecked ? primaryColor : Colors.grey[300]!, width: 2),
              color: isChecked ? primaryColor : Colors.transparent,
            ),
            child: isChecked ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
          ),
        ],
      ),
    );
  }
}
