import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import 'user_home_page.dart';

import 'package:intl/intl.dart';

class OrderSuccessPage extends StatelessWidget {
  final List<Product> items;
  final String paymentMethod;
  final String address;
  final String userName;
  final String mobile;

  const OrderSuccessPage({
    super.key, 
    required this.items,
    required this.paymentMethod,
    required this.address,
    required this.userName,
    required this.mobile,
  });

  final Color primaryColor = const Color(0xFFB10044);

  double _calculateTotal() {
    double total = 0;
    for (var item in items) {
      total += double.parse(item.price.replaceAll(',', ''));
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('MMMM dd, yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Shopidoe', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Success Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.check_circle, size: 60, color: primaryColor),
            ),
            const SizedBox(height: 32),
            const Text(
              'Order Placed\nSuccessfully!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thank you for choosing Shopidoe Boutique Store.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),

            // Order Details Card
            _buildInfoCard(
              'ORDER DETAILS',
              Row(
                children: [
                  _buildInfoItem('Date', dateStr),
                  const Spacer(),
                  _buildInfoItem('Time', timeStr, isRight: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Delivery Address Card
            _buildInfoCard(
              'DELIVERY ADDRESS',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(mobile, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 12),
                  Text(address, style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Order Summary Card (Dark Theme)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ORDER SUMMARY', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 16),
                  const Text('Total Amount Paid', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('₹${_calculateTotal().toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                    child: Text('PAID VIA ${paymentMethod.toUpperCase()}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            // Buttons
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {}, // View Details Logic
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('View Order Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const UserHomePage()),
                  (route) => false,
                );
              },
              child: const Text('Back to Home', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D2D2D))),
      ],
    );
  }
}
