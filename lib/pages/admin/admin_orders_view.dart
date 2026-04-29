import 'package:flutter/material.dart';

class AdminOrdersView extends StatelessWidget {
  const AdminOrdersView({super.key});

  Widget _buildOrderCard({
    required String status,
    required Color statusColor,
    Color? statusTextColor,
    required String id,
    required String name,
    required String details,
    required String price,
    required String actionText,
    required Color actionColor,
    bool isActionDisabled = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusTextColor ?? statusColor),
                ),
              ),
              Text('ID: $id', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
            ],
          ),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(details, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFB10044))),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isActionDisabled ? null : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[200],
                    disabledForegroundColor: Colors.grey[400],
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text(actionText, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {},
                child: const Text('Details', style: TextStyle(color: Color(0xFFB10044), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList({required bool isPresent}) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: isPresent ? [
        _buildOrderCard(
          status: 'IN PREPARATION',
          statusColor: Colors.blueGrey,
          id: '#FaSybN',
          name: 'saranraja',
          details: 'Omalur,Salem-12, salem - 636305 • 3 Items',
          price: '₹1316.00',
          actionText: 'Confirm Order',
          actionColor: Colors.blue,
        ),
        _buildOrderCard(
          status: 'CONFIRMED',
          statusColor: Colors.blue[100]!,
          statusTextColor: Colors.blue[700],
          id: '#6SBVdE',
          name: 'saranraja',
          details: 'Omalur,Salem-12, salem - 636305 • 1 Items',
          price: '₹76.00',
          actionText: 'Mark as Delivered',
          actionColor: const Color(0xFFB10044),
        ),
      ] : [
        _buildOrderCard(
          status: 'DELIVERED',
          statusColor: const Color(0xFFB10044),
          statusTextColor: const Color(0xFFB10044),
          id: '#1y3zJa',
          name: 'saranraja',
          details: 'Omalur,Salem-12, salem - 636305 • 1 Items',
          price: '₹105.00',
          actionText: 'Delivered',
          actionColor: Colors.grey[300]!,
          isActionDisabled: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              'Managing current store activity for Shopidoe Store',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF2D2D2D)),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: const Color(0xFFB10044),
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                tabs: const [
                  Tab(text: 'Present Orders'),
                  Tab(text: 'Past Orders'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOrderList(isPresent: true),
                _buildOrderList(isPresent: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
