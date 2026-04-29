import 'package:flutter/material.dart';

class AdminInventoryView extends StatelessWidget {
  const AdminInventoryView({super.key});

  Widget _buildInventoryItem(String name, String price, String category, String sku, bool isAvailable) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.image_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFB10044), borderRadius: BorderRadius.circular(8)),
                      child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                    Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: const Color(0xFFB10044)),
                        const SizedBox(width: 12),
                        const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        Text('#$sku', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('₹ $price', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB10044))),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('View Variants\nStatus', style: TextStyle(fontSize: 10, color: Colors.blue[700], decoration: TextDecoration.underline)),
                    Row(
                      children: [
                        Switch(value: isAvailable, onChanged: (v) {}, activeColor: const Color(0xFFB10044)),
                        Text('AVAILABLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                      ],
                    ),
                  ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            'Inventory Control',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Audit and update your product availability.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[400]),
                      const SizedBox(width: 12),
                      Text('Search products, categories...', style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.filter_list, color: Color(0xFFB10044)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildInventoryItem('Chicken Masala', '32', 'MASALA', 'SKU-1000', true),
              _buildInventoryItem('Cinthol', '36', 'SOAP', 'SKU-1001', true),
              _buildInventoryItem('Dove', '40', 'SOAP', 'SKU-1002', true),
            ],
          ),
        ),
      ],
    );
  }
}
