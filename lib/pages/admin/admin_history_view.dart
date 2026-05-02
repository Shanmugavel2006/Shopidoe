import 'package:flutter/material.dart';

class AdminHistoryView extends StatelessWidget {
  const AdminHistoryView({super.key});

  final Color primaryColor = const Color(0xFFB10044);

  Widget _buildHistoryItem(BuildContext context, String message, String time) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: primaryColor,
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
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600, 
                    color: isDark ? Colors.white : const Color(0xFF2D2D2D)
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                ),
              ],
            ),
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
          child: Row(
            children: [
              Text(
                'Complete History',
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A)
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Container(width: 40, height: 4, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: RefreshIndicator(
              onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
              color: primaryColor,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHistoryItem(context, 'New order received from saranraja', '29/4/2026 18:20'),
                  Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[100]),
                  _buildHistoryItem(context, 'New user "Varshini" registered', '28/4/2026 20:15'),
                  Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[100]),
                  _buildHistoryItem(context, 'New order received from saranraja', '28/4/2026 19:29'),
                  Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[100]),
                  _buildHistoryItem(context, 'New order received from saranraja', '28/4/2026 19:11'),
                  Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[100]),
                  _buildHistoryItem(context, 'New user "saranraja" registered', '28/4/2026 15:21'),
                  Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[100]),
                  _buildHistoryItem(context, 'New order received from saran', '27/4/2026 21:48'),
                  Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[100]),
                  _buildHistoryItem(context, 'New order received from saran', '27/4/2026 15:32'),
                  Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[100]),
                  _buildHistoryItem(context, 'New order received from saran', '27/4/2026 15:21'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
