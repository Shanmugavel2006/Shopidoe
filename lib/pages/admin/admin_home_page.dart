import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user/login_page.dart';
import 'admin_dashboard_view.dart';
import 'admin_orders_view.dart';
import 'admin_payments_view.dart';
import 'admin_inventory_view.dart';
import 'admin_users_view.dart';
import 'admin_add_product_view.dart';
import 'admin_analysis_view.dart';
import 'admin_history_view.dart';
import 'admin_settings_view.dart';
import 'admin_banners_view.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final Color primaryColor = const Color(0xFFB10044);
  int _selectedIndex = 0;
  int _orderInitialTab = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildDrawerItem(String title, IconData icon, {bool isSelected = false, bool isLogout = false, int? index}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon, 
          color: isLogout ? Colors.red[400] : (isSelected ? primaryColor : (isDark ? Colors.grey[400] : Colors.grey[600])),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red[400] : (isSelected ? primaryColor : (isDark ? Colors.grey[300] : Colors.grey[800])),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        onTap: () async {
          if (isLogout) {
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            }
          } else if (index != null) {
            setState(() {
              _selectedIndex = index;
              if (index != 1) _orderInitialTab = 0; // Reset order tab if navigating away
            });
            Navigator.pop(context);
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.grey[800]),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'Shopidoe Admin',
          style: TextStyle(color: isDark ? Colors.white : Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_outlined, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 40,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.storefront_outlined, size: 40, color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Shopidoe Admin',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem('Dashboard', Icons.grid_view_outlined, isSelected: _selectedIndex == 0, index: 0),
                  _buildDrawerItem('Orders', Icons.receipt_long_outlined, isSelected: _selectedIndex == 1, index: 1),
                  _buildDrawerItem('Payments', Icons.payments_outlined, isSelected: _selectedIndex == 2, index: 2),
                  _buildDrawerItem('Manage Items', Icons.inventory_2_outlined, isSelected: _selectedIndex == 3, index: 3),
                  _buildDrawerItem('Add Product', Icons.add_box_outlined, isSelected: _selectedIndex == 5, index: 5),
                  _buildDrawerItem('Analysis', Icons.analytics_outlined, isSelected: _selectedIndex == 6, index: 6),
                  _buildDrawerItem('History', Icons.history, isSelected: _selectedIndex == 7, index: 7),
                  _buildDrawerItem('Users', Icons.group_outlined, isSelected: _selectedIndex == 4, index: 4),
                  _buildDrawerItem('Banners', Icons.view_carousel_outlined, isSelected: _selectedIndex == 9, index: 9),
                  _buildDrawerItem('Settings', Icons.settings_outlined, isSelected: _selectedIndex == 8, index: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
                  ),
                  _buildDrawerItem('Logout', Icons.logout, isLogout: true),
                ],
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          AdminDashboardView(
            primaryColor: primaryColor,
            onTabChange: (index, {subTab}) {
              setState(() {
                _selectedIndex = index;
                if (subTab != null) _orderInitialTab = subTab;
              });
            },
          ),
          AdminOrdersView(key: ValueKey('orders_$_orderInitialTab'), initialTabIndex: _orderInitialTab),
          AdminPaymentsView(),
          AdminInventoryView(),
          AdminUsersView(),
          AdminAddProductView(),
          AdminAnalysisView(),
          AdminHistoryView(),
          AdminSettingsView(),
          const AdminBannersView(),
        ],
      ),
      floatingActionButton: _selectedIndex == 3 
        ? FloatingActionButton(
            onPressed: () => setState(() => _selectedIndex = 5), 
            backgroundColor: primaryColor, 
            child: const Icon(Icons.add, color: Colors.white),
          ) 
        : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex > 4 ? 0 : (_selectedIndex == 4 ? 3 : (_selectedIndex == 3 ? 2 : (_selectedIndex == 2 ? 1 : _selectedIndex))),
        onTap: (index) {
          if (index == 0) setState(() => _selectedIndex = 0);
          if (index == 1) setState(() => _selectedIndex = 1);
          if (index == 2) setState(() => _selectedIndex = 3);
          if (index == 3) setState(() => _selectedIndex = 4);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'DASH'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'ORDERS'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'ITEMS'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'USERS'),
        ],
      ),
    );
  }
}
