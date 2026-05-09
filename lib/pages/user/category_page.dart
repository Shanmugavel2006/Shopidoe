import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/category_utils.dart';
import '../../services/speech_service.dart';
import '../../services/search_suggestion_service.dart';
import 'category_detail_page.dart';

class CategoryPage extends StatefulWidget {
  final Function(String) onCategorySelected;
  final VoidCallback onBack;
  const CategoryPage({super.key, required this.onCategorySelected, required this.onBack});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> with SpeechRecognitionMixin<CategoryPage> {
  final Color primaryColor = const Color(0xFFB10044);
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<String> _categoryNames = [];

  @override
  void initState() {
    super.initState();
    _fetchCategoryNames();
  }

  Future<void> _fetchCategoryNames() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('categories').get();
      if (mounted) {
        setState(() {
          _categoryNames = snapshot.docs
              .map((doc) => doc.get('name') as String)
              .toSet()
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching category names: $e');
    }
  }

  void _listen() {
    toggleListening(
      controller: _searchController,
      onResult: (text) => setState(() => _searchQuery = text),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, IconData icon, Color bgColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onCategorySelected(title),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? Colors.grey[800]! : primaryColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(isDark ? 0.1 : 0.05),
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
                  color: bgColor.withOpacity(isDark ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: bgColor.withOpacity(0.3), width: 1),
                ),
                child: Icon(icon, color: bgColor, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: widget.onBack,
        ),
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
          IconButton(
            onPressed: () {}, 
            icon: Icon(Icons.shopping_bag_outlined, color: isDark ? Colors.white : Colors.black87)
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold, 
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A)
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Search categories...',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                        suffixIcon: IconButton(
                          icon: Icon(isListening ? Icons.mic : Icons.mic_none, color: primaryColor),
                          onPressed: _listen,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: SearchSuggestionService.getFilteredSuggestions(_searchQuery, _categoryNames.isNotEmpty ? _categoryNames : ['Stationery', 'Cosmetics', 'Accessories', 'Beauty', 'Bags'])
                            .map((suggestion) => ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.search, size: 20, color: Colors.grey),
                                  title: Text(
                                    suggestion,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.north_west, size: 16, color: Colors.grey),
                                  onTap: () {
                                    setState(() {
                                      _searchController.text = suggestion;
                                      _searchQuery = suggestion;
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ],
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
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.filter_list, size: 18, color: isDark ? Colors.white : Colors.black87),
                            const SizedBox(width: 8),
                            Text(
                              'Filter', 
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87
                              )
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('categories').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const SliverToBoxAdapter(child: Center(child: Text('Something went wrong')));
              if (snapshot.connectionState == ConnectionState.waiting) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));

              List<QueryDocumentSnapshot> categories = snapshot.data!.docs;

              // Apply search filter
              if (_searchQuery.isNotEmpty) {
                categories = categories.where((doc) => 
                  doc['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();
              }

              if (categories.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(
                        _searchQuery.isEmpty ? 'No categories available' : 'No matching categories found',
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  )
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final name = categories[index]['name'];
                      return _buildCategoryItem(
                        context,
                        name,
                        CategoryUtils.getIconForCategory(name),
                        CategoryUtils.getColorForCategory(name),
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
