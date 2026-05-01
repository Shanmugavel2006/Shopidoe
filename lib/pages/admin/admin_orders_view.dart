import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminOrdersView extends StatefulWidget {
  final int initialTabIndex;
  const AdminOrdersView({super.key, this.initialTabIndex = 0});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  final Color primaryColor = const Color(0xFFB10044);

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': newStatus});
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> orderData, String orderId) {
    final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
    final createdAt = orderData['createdAt'] as Timestamp?;
    final dateStr = createdAt != null ? DateFormat('MMM dd, yyyy - hh:mm a').format(createdAt.toDate()) : 'N/A';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 8),
              Text('ID: #$orderId', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Text('Date: $dateStr', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(height: 16),
              
              // User Details
              const Text('Customer Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Name: ${orderData['userName'] ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
              Text('Mobile: ${orderData['mobile'] ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
              Text('Address: ${orderData['address'] ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
              Text('Payment: ${orderData['paymentMethod'] ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Items List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('₹${orderData['totalAmount']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final imageUrl = item['imageUrl'] ?? '';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 50, height: 50,
                              color: Colors.grey[200],
                              child: imageUrl.isNotEmpty 
                                ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.image_not_supported, size: 20)) 
                                : const Icon(Icons.image_outlined, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('₹${item['price']}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildOrderCard({
    required BuildContext context,
    required String status,
    required Color statusColor,
    Color? statusTextColor,
    required String id,
    required String name,
    required String details,
    required String price,
    required String actionText,
    required Color actionColor,
    required Map<String, dynamic> orderData,
    bool isActionDisabled = false,
    VoidCallback? onActionPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
              Text('ID: #$id', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
            ],
          ),
          const SizedBox(height: 16),
          Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 4),
          Text(details, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFB10044))),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isActionDisabled ? null : onActionPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    disabledForegroundColor: Colors.grey[600],
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text(actionText, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => _showOrderDetails(context, orderData, id),
                child: const Text('Details', style: TextStyle(color: Color(0xFFB10044), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<QueryDocumentSnapshot> orders, {required bool isPresent}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (orders.isEmpty) {
      return Center(
        child: Text(isPresent ? 'No present orders' : 'No past orders', style: TextStyle(color: Colors.grey[600])),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final orderDoc = orders[index];
        final orderData = orderDoc.data() as Map<String, dynamic>;
        
        final String status = orderData['status'] ?? 'Ordered';
        final String name = orderData['userName'] ?? 'Unknown';
        final String address = orderData['address'] ?? '';
        final List items = orderData['items'] ?? [];
        final String details = '$address • ${items.length} Items';
        final String price = '₹${orderData['totalAmount'] ?? 0}';
        final String shortId = orderDoc.id.length > 6 ? orderDoc.id.substring(0, 6).toUpperCase() : orderDoc.id;

        if (status == 'Ordered') {
          return _buildOrderCard(
            context: context,
            status: 'IN PREPARATION',
            statusColor: Colors.blueGrey,
            id: shortId,
            name: name,
            details: details,
            price: price,
            actionText: 'Confirm Order',
            actionColor: Colors.blue,
            orderData: orderData,
            onActionPressed: () => _updateOrderStatus(orderDoc.id, 'Confirmed'),
          );
        } else if (status == 'Confirmed') {
          return _buildOrderCard(
            context: context,
            status: 'CONFIRMED',
            statusColor: Colors.blue[100]!,
            statusTextColor: Colors.blue[700],
            id: shortId,
            name: name,
            details: details,
            price: price,
            actionText: 'Mark as Delivered',
            actionColor: primaryColor,
            orderData: orderData,
            onActionPressed: () => _updateOrderStatus(orderDoc.id, 'Delivered'),
          );
        } else {
          return _buildOrderCard(
            context: context,
            status: 'DELIVERED',
            statusColor: primaryColor,
            statusTextColor: primaryColor,
            id: shortId,
            name: name,
            details: details,
            price: price,
            actionText: 'Delivered',
            actionColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            orderData: orderData,
            isActionDisabled: true,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      key: ValueKey(widget.initialTabIndex),
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              'Managing current store activity for Shopidoe Store',
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w500, 
                color: isDark ? Colors.grey[300] : const Color(0xFF2D2D2D)
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: primaryColor,
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Error loading orders'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final allOrders = snapshot.data?.docs ?? [];
                
                final presentOrders = allOrders.where((doc) {
                  final status = (doc.data() as Map<String, dynamic>)['status'] ?? '';
                  return status != 'Delivered';
                }).toList();

                final pastOrders = allOrders.where((doc) {
                  final status = (doc.data() as Map<String, dynamic>)['status'] ?? '';
                  return status == 'Delivered';
                }).toList();

                return TabBarView(
                  children: [
                    _buildOrderList(presentOrders, isPresent: true),
                    _buildOrderList(pastOrders, isPresent: false),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
