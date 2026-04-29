import 'package:flutter/material.dart';
import 'category_detail_page.dart';

class CategoryPage extends StatefulWidget {
  final Function(String) onCategorySelected;
  const CategoryPage({super.key, required this.onCategorySelected});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final Color primaryColor = const Color(0xFFB10044);
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'title': 'Cosmetics', 'icon': Icons.auto_awesome, 'color': const Color(0xFFB10044)},
    {'title': 'Care', 'icon': Icons.shield_outlined, 'color': Colors.blueGrey},
    {'title': 'Bath', 'icon': Icons.bathtub_outlined, 'color': Colors.blue},
    {'title': 'Hygiene', 'icon': Icons.clean_hands_outlined, 'color': Colors.teal},
    {'title': 'Fragrance', 'icon': Icons.air, 'color': Colors.indigo},
    {'title': 'Cleaning', 'icon': Icons.cleaning_services_outlined, 'color': Colors.brown},
    {'title': 'Health', 'icon': Icons.add_box_outlined, 'color': Colors.red},
    {'title': 'Accessories', 'icon': Icons.shopping_bag_outlined, 'color': Colors.orange},
    {'title': 'Puja', 'icon': Icons.temple_hindu_outlined, 'color': Colors.deepOrange},
    {'title': 'Herbal', 'icon': Icons.eco_outlined, 'color': Colors.green},
  ];

  List<Map<String, dynamic>> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories
        .where((c) => c['title'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Widget _buildCategoryItem(BuildContext context, String title, IconData icon, Color bgColor) {
    return GestureDetector(
      onTap: () => widget.onCategorySelected(title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: bgColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.shopping_bag, color: primaryColor),
            ),
            const SizedBox(width: 8),
            Text(
              'Shopidoe',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black87)),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Categories',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 20),
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: Icon(Icons.mic_none, color: primaryColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Explore our boutique collections',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.filter_list, size: 18, color: Colors.black87),
                        SizedBox(width: 8),
                        Text('Filter', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _filteredCategories.isEmpty
                  ? Center(child: Text('No categories found matching "$_searchQuery"'))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = _filteredCategories[index];
                        return _buildCategoryItem(
                          context,
                          category['title'],
                          category['icon'],
                          category['color'],
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
