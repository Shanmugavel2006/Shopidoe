import 'package:flutter/material.dart';

class AdminPaymentsView extends StatelessWidget {
  const AdminPaymentsView({super.key});

  void _showTransactionDetails(BuildContext context, String id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold, 
                    color: isDark ? Colors.white : Colors.black87
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB10044).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ID: $id',
                    style: const TextStyle(color: Color(0xFFB10044), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildDetailItem(context, Icons.phone_outlined, 'Phone', '9003892505'),
            _buildDetailItem(context, Icons.credit_card_outlined, 'Payment Method', 'Cash on Delivery'),
            _buildDetailItem(context, Icons.account_balance_wallet_outlined, 'Total Amount', '₹76.00'),
            _buildDetailItem(context, Icons.info_outline, 'Status', 'CONFIRMED'),
            _buildDetailItem(context, Icons.calendar_today_outlined, 'Order Date', '2026-04-28 19:29:44.275'),
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
              'Omalur,Salem-12, salem - 636305',
              style: TextStyle(fontSize: 15, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const Spacer(),
            SizedBox(
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

  Widget _buildPaymentCard(BuildContext context, {
    required String name,
    required String date,
    required String amount,
    required String status,
    required String method,
    required IconData icon,
    required String id,
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
                  Text(
                    '₹$amount', 
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w900, 
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A)
                    )
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
              Row(
                children: [
                  Icon(Icons.credit_card, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text(method, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                ],
              ),
              GestureDetector(
                onTap: () => _showTransactionDetails(context, id),
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
                Text(
                  'Search by customer or payment...', 
                  style: TextStyle(color: Colors.grey[500], fontSize: 14)
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildPaymentCard(
                context,
                name: 'saranraja',
                date: '29/4/2026',
                amount: '1316.00',
                status: 'IN PREPARATION',
                method: 'Credit/Debit Card',
                icon: Icons.credit_card,
                id: '#FaSybN8',
              ),
              _buildPaymentCard(
                context,
                name: 'saranraja',
                date: '28/4/2026',
                amount: '76.00',
                status: 'CONFIRMED',
                method: 'Cash on Delivery',
                icon: Icons.money,
                id: '#6SBVdEt9',
              ),
              _buildPaymentCard(
                context,
                name: 'saranraja',
                date: '28/4/2026',
                amount: '105.00',
                status: 'DELIVERED',
                method: 'Cash on Delivery',
                icon: Icons.money,
                id: '#0lqrrB2',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
