import 'package:flutter/material.dart';

class AdminAnalysisView extends StatelessWidget {
  const AdminAnalysisView({super.key});

  final Color primaryColor = const Color(0xFFB10044);

  Widget _buildBar(String day, double heightFactor) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 15,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Analysis',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 40),
          const Text(
            'Weekly Payment Collection',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 24),
          Container(
            height: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹20k', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                    Text('₹15k', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                    Text('₹10k', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                    Text('₹5k', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                    Text('₹0k', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                    const SizedBox(height: 18), // Space for labels
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) => const Divider(color: Color(0xFFF1F1F1), height: 1, thickness: 1)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBar('Mon', 0.6),
                          _buildBar('Tue', 0.8),
                          _buildBar('Wed', 0.4),
                          _buildBar('Thu', 0.9),
                          _buildBar('Fri', 0.55),
                          _buildBar('Sat', 0.7),
                          _buildBar('Sun', 0.85),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Payment Status Distribution',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard('Completed', '₹85,420', Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusCard('Pending', '₹12,250', Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Text(amount, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
        ],
      ),
    );
  }
}
