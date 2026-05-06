import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../services/speech_service.dart';
import '../../services/search_suggestion_service.dart';

class AdminPaymentsView extends StatefulWidget {
  const AdminPaymentsView({super.key});

  @override
  State<AdminPaymentsView> createState() => _AdminPaymentsViewState();
}

class _AdminPaymentsViewState extends State<AdminPaymentsView> with SpeechRecognitionMixin<AdminPaymentsView> {
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTransactionDetails(BuildContext context, String id, Map<String, dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final createdAt = data['createdAt'] as Timestamp?;
    final dateStr = createdAt != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt.toDate()) : 'N/A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Transaction Details',
                            style: TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold, 
                              color: isDark ? Colors.white : Colors.black87
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB10044).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'ID: #$id',
                            style: const TextStyle(color: Color(0xFFB10044), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildDetailItem(context, Icons.person_outline, 'Customer', data['userName'] ?? 'N/A'),
                    _buildDetailItem(context, Icons.phone_outlined, 'Phone', data['mobile'] ?? 'N/A'),
                    _buildDetailItem(context, Icons.credit_card_outlined, 'Payment Method', data['paymentMethod'] ?? 'N/A'),
                    _buildDetailItem(context, Icons.account_balance_wallet_outlined, 'Total Amount', '₹${data['totalAmount'] ?? '0.00'}'),
                    _buildDetailItem(context, Icons.info_outline, 'Status', data['status'] ?? 'N/A'),
                    _buildDetailItem(context, Icons.calendar_today_outlined, 'Order Date', dateStr),
                    const SizedBox(height: 40),
                    Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: isDark ? Colors.white : Colors.black87
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data['address'] ?? 'N/A',
                      style: TextStyle(fontSize: 15, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB10044),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 24),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                value, 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16, 
                  color: isDark ? Colors.white : Colors.black87
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(BuildContext context, String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction record? This action cannot be undone.'),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction deleted successfully')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting transaction: $e')));
        }
      }
    }
  }

  Widget _buildPaymentCard(BuildContext context, {
    required String name,
    required String date,
    required String amount,
    required String status,
    required String method,
    required IconData icon,
    required String id,
    required String fullId,
    required Map<String, dynamic> data,
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[50], 
                  shape: BoxShape.circle
                ),
                child: Icon(icon, color: const Color(0xFFB10044)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name, 
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: isDark ? Colors.white : Colors.black87
                      )
                    ),
                    Text(date, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹$amount', 
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.w900, 
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A)
                        )
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _deleteTransaction(context, fullId),
                        child: Icon(Icons.delete_outline, size: 18, color: Colors.red.withOpacity(0.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFB10044).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB10044))),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[100]),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.credit_card, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        method, 
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showTransactionDetails(context, id, data),
                child: const Text(
                  'View Details',
                  style: TextStyle(color: Color(0xFFB10044), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            'Payment Transactions',
            style: TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white : const Color(0xFF1A1A1A)
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFB10044), borderRadius: BorderRadius.circular(2))),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white, 
              borderRadius: BorderRadius.circular(12)
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[400]),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search by customer or payment...',
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                      border: InputBorder.none,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                          IconButton(
                            icon: Icon(isListening ? Icons.mic : Icons.mic_none, color: const Color(0xFFB10044)),
                            onPressed: _listen,
                          ),
                        ],
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
              children: SearchSuggestionService.getFilteredSuggestions(_searchQuery, ['Success', 'Pending', 'Failed', 'Recent Transactions'])
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
        const SizedBox(height: 32),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

              var orders = snapshot.data?.docs ?? [];
              
              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase();
                orders = orders.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['userName'] ?? '').toString().toLowerCase();
                  final method = (data['paymentMethod'] ?? '').toString().toLowerCase();
                  final id = doc.id.toLowerCase();
                  return name.contains(query) || method.contains(query) || id.contains(query);
                }).toList();
              }

              if (orders.isEmpty) return Center(child: Text(_searchQuery.isNotEmpty ? 'No results found' : 'No payment transactions found'));

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final data = orders[index].data() as Map<String, dynamic>;
                  final id = orders[index].id;
                  final createdAt = data['createdAt'] as Timestamp?;
                  final dateStr = createdAt != null ? DateFormat('dd/M/yyyy').format(createdAt.toDate()) : 'N/A';
                  final shortId = id.length > 6 ? id.substring(0, 6).toUpperCase() : id;

                  return _buildPaymentCard(
                    context,
                    name: data['userName'] ?? 'Unknown',
                    date: dateStr,
                    amount: data['totalAmount']?.toString() ?? '0.00',
                    status: data['status'] ?? 'N/A',
                    method: data['paymentMethod'] ?? 'N/A',
                    icon: data['paymentMethod'] == 'Cash on Delivery' ? Icons.money : Icons.credit_card,
                    id: shortId,
                    fullId: id,
                    data: data,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

