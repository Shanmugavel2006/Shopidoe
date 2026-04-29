import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'category_page.dart';
import 'profile_page.dart';
import 'login_page.dart';

import 'category_detail_page.dart';
import 'cart_page.dart';
import 'wishlist_page.dart';
import 'checkout_page.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  String? _selectedCategory;
  final Color primaryColor = const Color(0xFFB10044);

  Widget _buildCategoryTab() {
    if (_selectedCategory == null) {
      return CategoryPage(
        onCategorySelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
        },
      );
    } else {
      return CategoryDetailPage(
        categoryName: _selectedCategory!,
        onBack: () {
          setState(() {
            _selectedCategory = null;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const HomeContent(),
      _buildCategoryTab(),
      const CartPage(),
      const WishlistPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final Color primaryColor = const Color(0xFFB10044);
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Product> _allProducts = [
    Product(
      id: 'p1',
      category: 'Stationery',
      name: 'Blush Leather Journal',
      price: '1,299',
      status: 'In Stock',
      isAvailable: true,
      imageUrl: '',
    ),
    Product(
      id: 'p2',
      category: 'Cosmetics',
      name: 'Velvet Matte Lipstick',
      price: '850',
      status: 'Unavailable',
      isAvailable: false,
      imageUrl: '',
    ),
    Product(
      id: 'p3',
      category: 'Accessories',
      name: 'Rose Gold Watch',
      price: '4,499',
      status: 'In Stock',
      isAvailable: true,
      imageUrl: '',
    ),
    Product(
      id: 'p4',
      category: 'Lifestyle',
      name: 'Petal Scented Candle',
      price: '1,850',
      status: 'In Stock',
      isAvailable: true,
      imageUrl: '',
    ),
  ];

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return _allProducts;
    return _allProducts
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                      p.category.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: GestureDetector(
                    onTap: () {
                      if (product.imageUrl.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog.fullscreen(
                            backgroundColor: Colors.black,
                            child: Stack(
                              children: [
                                Center(
                                  child: InteractiveViewer(
                                    minScale: 0.5,
                                    maxScale: 4.0,
                                    child: Image.network(product.imageUrl, fit: BoxFit.contain),
                                  ),
                                ),
                                Positioned(
                                  top: 40,
                                  right: 20,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                Positioned(
                                  bottom: 40,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Text(
                                      product.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      color: const Color(0xFFF5F5F5),
                      width: double.infinity,
                      child: Center(
                        child: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                product.isAvailable ? Icons.shopping_bag_outlined : Icons.do_not_disturb_on_outlined,
                                size: 50,
                                color: Colors.grey[300],
                              ),
                            )
                          : Icon(
                              product.isAvailable ? Icons.shopping_bag_outlined : Icons.do_not_disturb_on_outlined,
                              size: 50,
                              color: Colors.grey[300],
                            ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.isAvailable ? Colors.white.withOpacity(0.9) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: product.isAvailable ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: StreamBuilder<bool>(
                    stream: CartService.isInWishlist(product.id),
                    builder: (context, snapshot) {
                      final isWishlisted = snapshot.data ?? false;
                      return GestureDetector(
                        onTap: () {
                          CartService.toggleWishlist(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isWishlisted ? 'Removed from Wishlist' : 'Added to Wishlist'), duration: const Duration(seconds: 1)),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isWishlisted ? primaryColor : Colors.grey[400],
                          ),
                        ),
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
          // Info Section
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.5,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.price}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                    ),
                  ),
                  const Spacer(),
                  // Buttons
                  if (product.isAvailable) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutPage(items: [product], isSingleProduct: true),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Buy Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          CartService.addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to Cart'), duration: Duration(seconds: 1)),
                          );
                        },
                        icon: Icon(Icons.shopping_cart_outlined, size: 14, color: primaryColor),
                        label: Text('Add to Cart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor.withOpacity(0.6), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text('Sold Out', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text('Notify Me', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            icon: Icon(Icons.logout, color: primaryColor),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Greeting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Good Morning, Sarah!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search for stationery, cosmetics...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: Icon(Icons.mic_none, color: primaryColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Banner
            if (_searchQuery.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  height: 210,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'),
                      fit: BoxFit.cover,
                      opacity: 0.8,
                    ),
                    gradient: LinearGradient(
                      colors: [Colors.pink[400]!, Colors.pink[200]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'NEW ARRIVAL',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'The Spring\nCollection\nis here.',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Up to 40% off on all accessories',
                          style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            // Curated Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _searchQuery.isEmpty ? 'Curated For You' : 'Search Results',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                  ),
                  if (_searchQuery.isEmpty)
                    Text(
                      'View All',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Product Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text('Error loading products'));
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                  List<Product> products = snapshot.data!.docs.map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>)).toList();

                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    products = products.where((p) => 
                      p.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                      p.category.toLowerCase().contains(_searchQuery.toLowerCase())
                    ).toList();
                  }

                  if (products.isEmpty) {
                    return Center(child: Text(_searchQuery.isEmpty ? 'No products available' : 'No products found matching "$_searchQuery"'));
                  }

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 0.50,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    children: products.map((p) => _buildProductCard(context, p)).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
