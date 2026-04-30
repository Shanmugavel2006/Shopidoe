import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardView extends StatelessWidget {
  final Color primaryColor;
  final Function(int) onTabChange;

  const AdminDashboardView({
    super.key, 
    required this.primaryColor, 
    required this.onTabChange
  });

  Widget _buildStatCard(String title, String streamPath, IconData icon, Color iconColor, int index) {
    return GestureDetector(
      onTap: () => onTabChange(index),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const Spacer(),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection(streamPath).snapshots(),
              builder: (context, snapshot) {
                String count = '...';
                if (snapshot.hasData) {
                  count = snapshot.data!.docs.length.toString();
                }
                return Text(
                  count,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String message, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[100], height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Store Statistics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: [
              _buildStatCard('Total Products', 'products', Icons.inventory_2_outlined, Colors.blue, 3),
              _buildStatCard('Registered Users', 'users', Icons.group_outlined, primaryColor, 4),
              _buildStatCard('Pending Orders', 'orders', Icons.assignment_late_outlined, Colors.pink, 1),
              _buildStatCard('Total Payments', 'payments', Icons.payments_outlined, Colors.purple, 2),
              _buildStatCard('Categories', 'categories', Icons.category_outlined, Colors.teal, 3),
              _buildStatCard('Order History', 'history', Icons.history, Colors.orange, 7),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                // Real Activity Logic: Combine multiple streams
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('products').orderBy('createdAt', descending: true).limit(2).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        return _buildActivityItem(
                          'New product "${doc['name']}" added',
                          'Recently',
                          Icons.add_box_outlined,
                          Colors.blue,
                        );
                      }).toList(),
                    );
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').limit(2).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        final name = doc['name'] ?? 'Unknown User';
                        return _buildActivityItem(
                          'New user "$name" registered',
                          'Recently',
                          Icons.person_add_alt_outlined,
                          primaryColor,
                        );
                      }).toList(),
                    );
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).limit(1).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
                    final doc = snapshot.data!.docs.first;
                    return _buildActivityItem(
                      'New order #${doc.id.substring(0, 5)} received',
                      'Recently',
                      Icons.receipt_long_outlined,
                      Colors.green,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
