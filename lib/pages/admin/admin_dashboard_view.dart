import 'package:flutter/material.dart';

class AdminDashboardView extends StatelessWidget {
  final Color primaryColor;
  const AdminDashboardView({super.key, required this.primaryColor});

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
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
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String message, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFB10044),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 13, color: Colors.grey[400]),
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
              _buildStatCard('Total Products', '22', Icons.inventory_2_outlined, Colors.blue),
              _buildStatCard('Registered Users', '2', Icons.group_outlined, const Color(0xFFB10044)),
              _buildStatCard('Delivery Register', '0', Icons.local_shipping_outlined, Colors.orange),
              _buildStatCard('Pending Orders', '2', Icons.assignment_late_outlined, Colors.pink),
              _buildStatCard('Completed Orders', '11', Icons.check_circle_outline, Colors.teal),
              _buildStatCard('Payments', '13', Icons.payments_outlined, Colors.purple),
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
                _buildActivityItem('New order received from saranraja', '38 mins ago'),
                _buildActivityItem('New user "Varshini" registered', '22 hours ago'),
                _buildActivityItem('New order received from saranraja', '23 hours ago'),
                _buildActivityItem('New order received from saranraja', '23 hours ago'),
                _buildActivityItem('New user "saranraja" registered', '1 days ago'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
