import 'package:flutter/material.dart';

class AdminAnalysisView extends StatelessWidget {
  const AdminAnalysisView({super.key});

  final Color primaryColor = const Color(0xFFB10044);

  Widget _buildBar(BuildContext context, String day, double heightFactor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 15,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
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
        Text(
          day, 
          style: TextStyle(
            fontSize: 10, 
            fontWeight: FontWeight.bold, 
            color: isDark ? Colors.grey[400] : Colors.grey[600]
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RefreshIndicator(
      onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
      color: primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Analysis',
            style: TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white : const Color(0xFF1A1A1A)
            ),
          ),
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 40),
          Text(
            'Weekly Payment Collection',
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white : const Color(0xFF1A1A1A)
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹20k', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    Text('₹15k', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    Text('₹10k', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    Text('₹5k', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    Text('₹0k', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    const SizedBox(height: 18), // Space for labels
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) => Divider(color: isDark ? Colors.grey[800] : const Color(0xFFF1F1F1), height: 1, thickness: 1)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBar(context, 'Mon', 0.6),
                          _buildBar(context, 'Tue', 0.8),
                          _buildBar(context, 'Wed', 0.4),
                          _buildBar(context, 'Thu', 0.9),
                          _buildBar(context, 'Fri', 0.55),
                          _buildBar(context, 'Sat', 0.7),
                          _buildBar(context, 'Sun', 0.85),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Payment Status Distribution',
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white : const Color(0xFF1A1A1A)
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(context, 'Completed', '₹85,420', Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusCard(context, 'Pending', '₹12,250', Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}

  Widget _buildStatusCard(BuildContext context, String label, String amount, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Text(
            amount, 
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.w900, 
              color: isDark ? Colors.white : const Color(0xFF1A1A1A)
            )
          ),
        ],
      ),
    );
  }
}
