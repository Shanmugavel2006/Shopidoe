import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminAnalysisView extends StatefulWidget {
  const AdminAnalysisView({super.key});

  @override
  State<AdminAnalysisView> createState() => _AdminAnalysisViewState();
}

class _AdminAnalysisViewState extends State<AdminAnalysisView> {
  final Color primaryColor = const Color(0xFFB10044);
  String _selectedView = 'Weekly';

  Widget _buildBar(BuildContext context, String label, double amount, double maxAmount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double heightFactor = maxAmount > 0 ? (amount / maxAmount).clamp(0.05, 1.0) : 0.05;
    
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 15,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label, 
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
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading analysis'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final orders = snapshot.data!.docs;
        
        // Calculations
        double totalCompleted = 0;
        double totalPending = 0;
        Map<String, double> chartData = {};
        
        // Initialize chart data based on view
        List<String> labels = [];
        if (_selectedView == 'Weekly') {
          labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          for (var l in labels) {
            chartData[l] = 0;
          }
        } else {
          labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          for (var l in labels) {
            chartData[l] = 0;
          }
        }

        for (var doc in orders) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = double.tryParse(data['totalAmount']?.toString().replaceAll(',', '') ?? '0') ?? 0.0;
          final status = data['status'] ?? 'Ordered';
          final timestamp = data['createdAt'] as Timestamp?;

          if (status == 'Delivered') {
            totalCompleted += amount;
          } else {
            totalPending += amount;
          }

          if (timestamp != null) {
            final date = timestamp.toDate();
            if (_selectedView == 'Weekly') {
              // Only include orders from the current week
              final now = DateTime.now();
              final weekStart = now.subtract(Duration(days: now.weekday - 1));
              if (date.isAfter(weekStart.subtract(const Duration(seconds: 1)))) {
                final dayLabel = DateFormat('E').format(date);
                if (chartData.containsKey(dayLabel)) {
                  chartData[dayLabel] = (chartData[dayLabel] ?? 0) + amount;
                }
              }
            } else {
              // Monthly view for the current year
              if (date.year == DateTime.now().year) {
                final monthLabel = DateFormat('MMM').format(date);
                if (chartData.containsKey(monthLabel)) {
                  chartData[monthLabel] = (chartData[monthLabel] ?? 0) + amount;
                }
              }
            }
          }
        }

        double maxChartAmount = 0;
        chartData.values.forEach((v) { if (v > maxChartAmount) maxChartAmount = v; });
        if (maxChartAmount == 0) maxChartAmount = 1000; // Default scale

        return RefreshIndicator(
          onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
          color: primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
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
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedView,
                          icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                          items: ['Weekly', 'Monthly'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedView = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  '$_selectedView Payment Collection',
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
                          Text('₹${(maxChartAmount/1000).toStringAsFixed(1)}k', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                          Text('₹${(maxChartAmount*0.75/1000).toStringAsFixed(1)}k', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                          Text('₹${(maxChartAmount*0.5/1000).toStringAsFixed(1)}k', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                          Text('₹${(maxChartAmount*0.25/1000).toStringAsFixed(1)}k', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
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
                              children: labels.map((label) => _buildBar(context, label, chartData[label] ?? 0, maxChartAmount)).toList(),
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
                      child: _buildStatusCard(context, 'Completed', '₹${NumberFormat('#,##,###').format(totalCompleted)}', Colors.green),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatusCard(context, 'Pending', '₹${NumberFormat('#,##,###').format(totalPending)}', Colors.orange),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
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
