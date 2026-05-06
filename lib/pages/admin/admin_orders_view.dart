import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/speech_service.dart';
import '../../services/search_suggestion_service.dart';

class AdminOrdersView extends StatefulWidget {
  final int initialTabIndex;
  const AdminOrdersView({super.key, this.initialTabIndex = 0});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> with SpeechRecognitionMixin<AdminOrdersView> {
  final Color primaryColor = const Color(0xFFB10044);
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void _listen() {
    toggleListening(
      controller: _searchController,
      onResult: (text) => setState(() => _searchQuery = text),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.9),
              ),
            ),
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.white, size: 50),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': newStatus});
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }

  Future<void> _deleteOrder(BuildContext context, String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text('Are you sure you want to delete this order? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order deleted successfully')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting order: $e')));
        }
      }
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
              const SizedBox(height: 12),
              _buildDetailRow(Icons.person, 'Name', orderData['userName'] ?? 'N/A'),
              _buildDetailRow(Icons.phone, 'Mobile', orderData['mobile'] ?? 'N/A'),
              _buildDetailRow(Icons.location_on, 'Address', orderData['address'] ?? 'N/A'),
              if (orderData['city'] != null) _buildDetailRow(Icons.location_city, 'City', orderData['city']),
              if (orderData['zip'] != null) _buildDetailRow(Icons.pin_drop, 'Zip Code', orderData['zip']),
              _buildDetailRow(Icons.payment, 'Payment', orderData['paymentMethod'] ?? 'N/A'),

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
                    final int qty = item['quantity'] ?? 1;
                    final double price = double.tryParse(item['price'].toString().replaceAll(',', '')) ?? 0.0;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _showFullScreenImage(context, imageUrl),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 60, height: 60,
                                color: Colors.grey[200],
                                child: imageUrl.isNotEmpty 
                                  ? CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                                      errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                                    ) 
                                  : const Icon(Icons.image_outlined, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text('ID: ${item['id']?.toString().substring(0, 8) ?? 'N/A'}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('₹$price x $qty', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                    Text('₹${(price * qty).toStringAsFixed(2)}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
        ],
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
              Row(
                children: [
                  Text('ID: #$id', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _deleteOrder(context, orderData['id'] ?? id),
                    child: Icon(Icons.delete_outline, size: 16, color: Colors.red.withOpacity(0.7)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 4),
          Text(details, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFB10044))),
          const SizedBox(height: 12),
          // Product Thumbnails
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: (orderData['items'] as List?)?.length ?? 0,
              itemBuilder: (context, index) {
                final item = (orderData['items'] as List)[index];
                final String img = item['imageUrl'] ?? '';
                return GestureDetector(
                  onTap: () => _showFullScreenImage(context, img),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: img.isNotEmpty 
                        ? CachedNetworkImage(
                            imageUrl: img,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: isDark ? Colors.grey[800] : Colors.grey[100]),
                            errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 14),
                          ) 
                        : const Icon(Icons.image_outlined, size: 14, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
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

    return RefreshIndicator(
      onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
      color: primaryColor,
      child: ListView.builder(
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
      ),
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[400]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Search orders by name or address...',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(isListening ? Icons.mic : Icons.mic_none, color: primaryColor),
                          onPressed: _listen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: SearchSuggestionService.getFilteredSuggestions(_searchQuery, SearchSuggestionService.adminOrderSuggestions)
                    .map((suggestion) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.search, size: 20, color: Colors.grey),
                          title: Text(
                            suggestion,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const Icon(Icons.north_west, size: 16, color: Colors.grey),
                          onTap: () {
                            setState(() {
                              _searchController.text = suggestion;
                              _searchQuery = suggestion;
                            });
                          },
                        ))
                    .toList(),
              ),
            ),
          ],
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

                var allOrders = snapshot.data?.docs ?? [];
                
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  allOrders = allOrders.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['userName'] ?? '').toString().toLowerCase();
                    final address = (data['address'] ?? '').toString().toLowerCase();
                    return name.contains(query) || address.contains(query);
                  }).toList();
                }

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
