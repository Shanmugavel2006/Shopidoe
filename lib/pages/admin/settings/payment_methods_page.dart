import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final Color primaryColor = const Color(0xFFB10044);
  bool _isLoading = true;
  
  Map<String, dynamic> _settings = {
    'codEnabled': true,
    'onlineEnabled': true,
    'upiEnabled': false,
  };

  @override
  void initState() {
    super.initState();
    _fetchPaymentSettings();
  }

  Future<void> _fetchPaymentSettings() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc('payment_methods').get();
      if (doc.exists) {
        setState(() {
          _settings = doc.data() ?? _settings;
        });
      }
    } catch (e) {
      debugPrint('Error fetching payment settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSetting(String key, bool value) async {
    setState(() {
      _settings[key] = value;
    });
    try {
      await FirebaseFirestore.instance.collection('settings').doc('payment_methods').set(_settings, SetOptions(merge: true));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Configure Payment Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Enable or disable payment methods for users at checkout.',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
              const SizedBox(height: 32),
              _buildPaymentTile(
                'Cash on Delivery (COD)',
                'Allow customers to pay when receiving items',
                Icons.payments_outlined,
                Colors.green,
                'codEnabled',
              ),
              _buildPaymentTile(
                'Online Payment',
                'Accept credit/debit cards and net banking',
                Icons.credit_card_outlined,
                Colors.blue,
                'onlineEnabled',
              ),
              _buildPaymentTile(
                'UPI / Scan & Pay',
                'Enable direct UPI payments via QR code',
                Icons.qr_code_scanner,
                Colors.purple,
                'upiEnabled',
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Note: At least one payment method must be enabled for users to place orders.',
                        style: TextStyle(color: Colors.orange[800], fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildPaymentTile(String title, String subtitle, IconData icon, Color color, String settingKey) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isEnabled = _settings[settingKey] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
        border: Border.all(color: isEnabled ? color.withOpacity(0.3) : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (v) => _toggleSetting(settingKey, v),
            activeColor: color,
          ),
        ],
      ),
    );
  }
}
