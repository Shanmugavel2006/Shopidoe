import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final Color primaryColor = const Color(0xFFB10044);
  bool _isLoading = true;

  Map<String, dynamic> _settings = {
    'newOrderAlert': true,
    'inventoryAlert': true,
    'customerSignupAlert': false,
    'emailSummary': true,
  };

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc('notifications').get();
      if (doc.exists) {
        setState(() {
          _settings = doc.data() ?? _settings;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSetting(String key, bool val) async {
    setState(() => _settings[key] = val);
    await FirebaseFirestore.instance.collection('settings').doc('notifications').set(_settings, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text('Admin Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSwitchTile('New Order Alert', 'Receive notifications when a new order is placed', 'newOrderAlert'),
              _buildSwitchTile('Low Inventory Alert', 'Notify when product stock is low', 'inventoryAlert'),
              _buildSwitchTile('User Registrations', 'Alert when a new customer signs up', 'customerSignupAlert'),
              
              const SizedBox(height: 32),
              const Text('Email Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSwitchTile('Daily Sales Summary', 'Get a daily summary of total sales and orders', 'emailSummary'),
            ],
          ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, String key) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        trailing: Switch(
          value: _settings[key] ?? false,
          onChanged: (v) => _updateSetting(key, v),
          activeColor: primaryColor,
        ),
      ),
    );
  }
}
