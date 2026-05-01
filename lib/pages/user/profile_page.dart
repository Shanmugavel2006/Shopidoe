import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';
import '../../main.dart';
import '../../services/cloudinary_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color primaryColor = const Color(0xFFB10044);
  final Color lightBgColor = const Color(0xFFF8F9FA);

  void _showSettingsBottomSheet() {
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
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dark Mode',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                  builder: (_, mode, __) {
                    return Switch(
                      value: mode == ThemeMode.dark,
                      onChanged: (v) {
                        themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                        Navigator.pop(context);
                      },
                      activeColor: primaryColor,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadProfileImage() async {
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
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'profileImageUrl': url,
          });
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

  void _showProfileOptions(Map<String, dynamic> userData, String email) {
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
              leading: Icon(Icons.edit, color: primaryColor),
              title: const Text('Edit Image', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadProfileImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: primaryColor),
              title: const Text('Show Details', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _showUserDetailsDialog(userData, email);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetailsDialog(Map<String, dynamic> userData, String email) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('User Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailRow('Name', userData['name'] ?? 'Not set'),
              _buildDetailRow('Email', email),
              _buildDetailRow('Mobile', userData['mobile'] ?? 'Not set'),
              _buildDetailRow('Address', userData['address'] ?? 'Not set'),
              _buildDetailRow('Joined Date', userData['createdAt'] != null ? DateFormat('dd MMM, yyyy').format((userData['createdAt'] as Timestamp).toDate()) : 'Not available'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> _editAddress(String currentAddress) async {
    final TextEditingController addressController = TextEditingController(text: currentAddress);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Address'),
        content: TextField(
          controller: addressController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter new address',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                  'address': addressController.text.trim(),
                });
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _viewAllPastOrders(List<QueryDocumentSnapshot> pastOrders) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Past History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              Expanded(
                child: pastOrders.isEmpty
                  ? const Center(child: Text('No past orders'))
                  : ListView.builder(
                      itemCount: pastOrders.length,
                      itemBuilder: (context, index) {
                        final data = pastOrders[index].data() as Map<String, dynamic>;
                        final shortId = pastOrders[index].id.substring(0, 6).toUpperCase();
                        final amount = data['totalAmount'] ?? 0;
                        final date = data['createdAt'] != null ? DateFormat('dd MMM, yyyy').format((data['createdAt'] as Timestamp).toDate()) : '';
                        
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(backgroundColor: primaryColor.withOpacity(0.1), child: Icon(Icons.history, color: primaryColor)),
                          title: Text('Order #$shortId', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(date),
                          trailing: Text('₹$amount', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Scaffold(body: Center(child: Text('Not logged in')));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _showSettingsBottomSheet,
            icon: Icon(Icons.settings, color: primaryColor),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
            final userName = userData['name'] ?? 'User';
            final email = currentUser.email ?? 'No email';
            final mobile = userData['mobile'] ?? 'No mobile';
            final address = userData['address'] ?? 'No address saved';
            final profileImageUrl = userData['profileImageUrl'] ?? 'https://i.pravatar.cc/150?img=68';

            return Column(
              children: [
                const SizedBox(height: 20),
                // Profile Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : lightBgColor,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _showProfileOptions(userData, email),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF66BB6A), width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(profileImageUrl),
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
                                child: const Icon(Icons.edit, color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userName,
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.email_outlined, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                email,
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.phone_outlined, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              mobile,
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('orders')
                      .where('userId', isEqualTo: currentUser.uid)
                      .snapshots(),
                  builder: (context, ordersSnapshot) {
                    if (ordersSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final docs = ordersSnapshot.data?.docs ?? [];
                    final allOrders = docs.toList()..sort((a, b) {
                      final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                      final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                      if (aTime == null || bTime == null) return 0;
                      return bTime.compareTo(aTime);
                    });
                    final activeOrders = allOrders.where((doc) {
                      final status = (doc.data() as Map<String, dynamic>)['status'] ?? '';
                      return status != 'Delivered';
                    }).toList();
                    final pastOrders = allOrders.where((doc) {
                      final status = (doc.data() as Map<String, dynamic>)['status'] ?? '';
                      return status == 'Delivered';
                    }).toList();

                    // Most recent active order for status tracking
                    Map<String, dynamic>? latestActiveData;
                    String latestActiveId = '';
                    if (activeOrders.isNotEmpty) {
                      latestActiveData = activeOrders.first.data() as Map<String, dynamic>;
                      latestActiveId = activeOrders.first.id.substring(0, 6).toUpperCase();
                    } else if (allOrders.isNotEmpty) {
                      latestActiveData = allOrders.first.data() as Map<String, dynamic>;
                      latestActiveId = allOrders.first.id.substring(0, 6).toUpperCase();
                    }

                    final bool isOrdered = latestActiveData != null;
                    final bool isConfirmed = latestActiveData != null && (latestActiveData['status'] == 'Confirmed' || latestActiveData['status'] == 'Delivered');
                    final bool isDelivered = latestActiveData != null && latestActiveData['status'] == 'Delivered';

                    return Column(
                      children: [
                        // Order Status Section
                        if (latestActiveData != null)
                          _buildSectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Order Status', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                    Text('#$latestActiveId', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                _buildStatusRow('Ordered', isOrdered),
                                _buildStatusRow('Order Confirmed', isConfirmed),
                                _buildStatusRow('Delivered', isDelivered),
                              ],
                            ),
                          ),
                          
                        if (latestActiveData != null) const SizedBox(height: 20),

                        // Present Orders Section
                        if (activeOrders.isNotEmpty)
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
                                      child: Text('${activeOrders.length} ACTIVE', style: const TextStyle(color: Color(0xFF1B4332), fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...activeOrders.map((doc) {
                                  final order = doc.data() as Map<String, dynamic>;
                                  final shortId = doc.id.substring(0, 6).toUpperCase();
                                  final amount = order['totalAmount'] ?? 0;
                                  final status = order['status'] ?? 'Ordered';
                                  final date = order['createdAt'] != null ? DateFormat('dd MMM, hh:mm a').format((order['createdAt'] as Timestamp).toDate()) : '';
                                  
                                  int steps = 1;
                                  if (status == 'Confirmed') steps = 2;
                                  if (status == 'Delivered') steps = 3;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Order #$shortId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            Text('₹$amount', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(date, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(child: Container(height: 6, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(3)))),
                                            const SizedBox(width: 8),
                                            Expanded(child: Container(height: 6, decoration: BoxDecoration(color: steps >= 2 ? primaryColor : Colors.grey[300], borderRadius: BorderRadius.circular(3)))),
                                            const SizedBox(width: 8),
                                            Expanded(child: Container(height: 6, decoration: BoxDecoration(color: steps >= 3 ? primaryColor : Colors.grey[300], borderRadius: BorderRadius.circular(3)))),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(status.toUpperCase(), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),

                        if (activeOrders.isNotEmpty) const SizedBox(height: 20),

                        // Past History Section
                        _buildSectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Past History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                  GestureDetector(
                                    onTap: () => _viewAllPastOrders(pastOrders),
                                    child: Text('VIEW ALL', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (pastOrders.isEmpty)
                                const Text('No past orders', style: TextStyle(color: Colors.grey))
                              else ...pastOrders.take(2).map((doc) {
                                final order = doc.data() as Map<String, dynamic>;
                                final shortId = doc.id.substring(0, 6).toUpperCase();
                                final amount = order['totalAmount'] ?? 0;
                                final date = order['createdAt'] != null ? DateFormat('dd MMM, yyyy').format((order['createdAt'] as Timestamp).toDate()) : '';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
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
                                            Text('Order #$shortId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            Text(date, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      Text('₹$amount', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
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
                          GestureDetector(
                            onTap: () => _editAddress(address),
                            child: Text('Edit / Add', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(address, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Logout Button
                TextButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 40),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F4).withOpacity(0.5),
        borderRadius: BorderRadius.circular(40),
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
              border: Border.all(color: isChecked ? primaryColor : Colors.grey[500]!, width: 2),
              color: isChecked ? primaryColor : Colors.transparent,
            ),
            child: isChecked ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
          ),
        ],
      ),
    );
  }
}
