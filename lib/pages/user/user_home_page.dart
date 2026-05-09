import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'category_page.dart';
import 'profile_page.dart';
import 'login_page.dart';

import 'category_detail_page.dart';
import 'cart_page.dart';
import 'wishlist_page.dart';
import 'checkout_page.dart';
import 'product_details_page.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:share_plus/share_plus.dart';
import 'package:app_links/app_links.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/speech_service.dart';
import '../../services/search_suggestion_service.dart';

import '../../main.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  String? _selectedCategory;
  final Color primaryColor = const Color(0xFFB10044);
  DateTime? _lastPressedAt;

  Widget _buildCategoryTab() {
    if (_selectedCategory == null) {
      return CategoryPage(
        onCategorySelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
        },
        onBack: () => setState(() => _selectedIndex = 0),
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
      CartPage(onBack: () => setState(() => _selectedIndex = 0)),
      WishlistPage(onBack: () => setState(() => _selectedIndex = 0)),
      ProfilePage(onBack: () => setState(() => _selectedIndex = 0)),
    ];

    return PortalTheme(
      notifier: userThemeNotifier,
      child: Builder(
        builder: (context) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;

              // 1. If the Navigator can pop (a real page was pushed), pop it
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
                return;
              }

              // 2. If we are in Category Detail, go back to Category list
              if (_selectedIndex == 1 && _selectedCategory != null) {
                setState(() => _selectedCategory = null);
                return;
              }

              // 3. If we are on any other tab, go back to Home tab
              if (_selectedIndex != 0) {
                setState(() => _selectedIndex = 0);
                return;
              }

              // 4. Otherwise, handle double-press to exit logic
              final now = DateTime.now();
              final backButtonHasNotBeenPressedRecently = _lastPressedAt == null || 
                  now.difference(_lastPressedAt!) > const Duration(seconds: 2);

              if (backButtonHasNotBeenPressedRecently) {
                _lastPressedAt = now;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Press back again to exit'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              final shouldPop = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Exit App'),
                  content: const Text('Are you sure you want to exit?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Yes', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (shouldPop == true) {
                SystemNavigator.pop();
              }
            },
            child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          unselectedItemColor: primaryColor, // Makes unselected labels pink
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled, color: _selectedIndex == 0 ? primaryColor : Colors.grey[400]),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded, color: _selectedIndex == 1 ? primaryColor : Colors.grey[400]),
              label: 'CATEGORIES',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_rounded, color: _selectedIndex == 2 ? primaryColor : Colors.grey[400]),
              label: 'CART',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded, color: _selectedIndex == 3 ? primaryColor : Colors.grey[400]),
              label: 'WISHLIST',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded, color: _selectedIndex == 4 ? primaryColor : Colors.grey[400]),
              label: 'ACCOUNT',
            ),
          ],
        ),
            ),
          );
        },
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with SpeechRecognitionMixin<HomeContent> {
  final Color primaryColor = const Color(0xFFB10044);
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _userName = 'User';
  List<String> _productNames = [];
  bool _showSuggestions = true;

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchProductNames();
    _initAppLinks();
  }

  Future<void> _fetchProductNames() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('products').get();
      if (mounted) {
        setState(() {
          _productNames = snapshot.docs
              .map((doc) => doc.get('name') as String)
              .toSet()
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching product names: $e');
    }
  }

  Future<void> _initAppLinks() async {
    _appLinks = AppLinks();
    
    // Check initial link if app was closed
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleAppLink(initialLink);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }
    
    // Handle link when app is in background
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleAppLink(uri);
    });
  }

  void _handleAppLink(Uri uri) async {
    // Example uri: https://shopidoe.app/product/PRODUCT_ID
    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'product') {
      final productId = uri.pathSegments[1];
      try {
        final doc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
        if (doc.exists && mounted) {
           final data = doc.data() as Map<String, dynamic>;
           data['id'] = doc.id;
           final product = Product.fromMap(data);
           // Show the variant picker/details
           _showVariantPicker(context, product, buyNow: false);
        } else {
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Product not found')),
             );
           }
        }
      } catch (e) {
        debugPrint('Error fetching shared product: $e');
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _userName = doc.get('name') ?? 'User';
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    // Since we use StreamBuilder, it updates automatically, 
    // but we can re-fetch the user name or just simulate a delay for UX
    await _fetchUserName();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _listen() {
    toggleListening(
      controller: _searchController,
      onResult: (text) => setState(() => _searchQuery = text),
    );
  }


  void _showVariantPicker(BuildContext context, Product product, {required bool buyNow}) {
    if (product.variants.isEmpty) {
      if (buyNow) {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => CheckoutPage(items: [product], isSingleProduct: true),
        ));
      } else {
        CartService.addToCart(product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to Cart'), duration: Duration(seconds: 1)),
        );
      }
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4, height: 24,
                        decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pick a Variant',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: product.variants.length,
                  itemBuilder: (context, index) {
                    final v = product.variants[index];
                    final isAvailable = v['isAvailable'] == true;
                    final variantProduct = Product(
                      id: '${product.id}_${v['name']}',
                      name: '${product.name} - ${v['name'] ?? ''}',
                      category: product.category,
                      price: v['price'] ?? product.price,
                      status: isAvailable ? 'In Stock' : 'Out of Stock',
                      isAvailable: isAvailable,
                      imageUrl: (v['imageUrl'] != null && (v['imageUrl'] as String).isNotEmpty)
                          ? v['imageUrl'] : product.imageUrl,
                      description: product.description,
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isAvailable 
                            ? Theme.of(context).cardColor 
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[50]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isAvailable 
                                ? primaryColor.withOpacity(0.3) 
                                : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[200]!)),
                        boxShadow: isAvailable ? [
                           BoxShadow(
                               color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.04), 
                               blurRadius: 10, 
                               offset: const Offset(0, 4))
                        ] : [],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => ProductDetailsPage(product: variantProduct),
                                  ));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 100, height: 100,
                                    color: Colors.grey[100],
                                    child: variantProduct.imageUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: variantProduct.imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(color: Colors.grey[100]),
                                            errorWidget: (context, url, error) => Icon(Icons.image_outlined, color: Colors.grey[400], size: 30),
                                          )
                                        : Icon(Icons.image_outlined, color: Colors.grey[400], size: 30),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(v['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                                        ),
                                        StreamBuilder<bool>(
                                          stream: CartService.isInWishlist(variantProduct.id),
                                          builder: (context, snapshot) {
                                            final isWishlisted = snapshot.data ?? false;
                                            return GestureDetector(
                                              onTap: () {
                                                CartService.toggleWishlist(variantProduct);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(isWishlisted ? 'Removed from Wishlist' : 'Added to Wishlist'), duration: const Duration(seconds: 1)),
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                child: Icon(
                                                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                                                  color: isWishlisted ? primaryColor : Colors.grey[400],
                                                  size: 22,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('₹${v['price'] ?? product.price}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 18)),
                                    const SizedBox(height: 8),
                                    if (!isAvailable)
                                      Text('Sold Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (isAvailable) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        CartService.addToCart(variantProduct);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('${v['name']} added to Cart'), duration: const Duration(seconds: 1)),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: primaryColor),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: Text('Add to Cart', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => CheckoutPage(items: [variantProduct], isSingleProduct: true),
                                        ));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        elevation: 0,
                                      ),
                                      child: const Text('Buy Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => ProductDetailsPage(product: product),
                      ));
                    },
                    child: Container(
                      color: const Color(0xFFF5F5F5),
                      width: double.infinity,
                      child: Center(
                        child: product.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => Container(color: const Color(0xFFF5F5F5)),
                              errorWidget: (context, url, error) => Icon(
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
                      color: product.isAvailable ? Theme.of(context).cardColor.withOpacity(0.9) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: product.isAvailable ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87) : Colors.grey[600],
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
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
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
                Positioned(
                  top: 50,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      final String shareText = 'Check out ${product.name} for ₹${product.price} at Shopidoe App!\n\nhttps://shopidoe.app/product/${product.id}';
                      Share.share(shareText);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.share_outlined,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                    ),
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
                    product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF2D2D2D),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.description.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 0.5,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    '₹${product.price}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Spacer(),
                  // Buttons
                  if (product.isAvailable) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () => _showVariantPicker(context, product, buyNow: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          product.variants.isNotEmpty ? 'Buy Now ▾' : 'Buy Now',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: OutlinedButton.icon(
                        onPressed: () => _showVariantPicker(context, product, buyNow: false),
                        icon: Icon(Icons.shopping_cart_outlined, size: 14, color: primaryColor),
                        label: Text(
                          product.variants.isNotEmpty ? 'Add to Cart ▾' : 'Add to Cart',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
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
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: primaryColor,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Greeting
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      '${_getGreeting()}, $_userName!',
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
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor, width: 1.5),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _showSuggestions = true;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search for stationery, cosmetics...',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                          suffixIcon: IconButton(
                            icon: Icon(isListening ? Icons.mic : Icons.mic_none, color: primaryColor),
                            onPressed: _listen,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty && _showSuggestions) ...[
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: SearchSuggestionService.getFilteredSuggestions(_searchQuery, _productNames.isNotEmpty ? _productNames : SearchSuggestionService.userSuggestions)
                              .map((suggestion) => ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.history, size: 20, color: Colors.grey),
                                    title: Text(
                                      suggestion,
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.north_west, size: 16, color: Colors.grey),
                                    onTap: () {
                                      setState(() {
                                        _searchController.text = suggestion;
                                        _searchQuery = suggestion;
                                        _showSuggestions = false;
                                      });
                                      FocusScope.of(context).unfocus();
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_searchQuery.isEmpty)
                    const BannerCarousel(),
                  const SizedBox(height: 32),
                  // Curated Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _searchQuery.isEmpty ? 'Curated For You' : 'Search Results',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF2D2D2D)),
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
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const SliverToBoxAdapter(child: Center(child: Text('Error loading products')));
                if (snapshot.connectionState == ConnectionState.waiting) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));

                List<Product> products = snapshot.data!.docs.map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>)).toList();
                products.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  products = products.where((p) => 
                    p.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                    p.category.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }

                if (products.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text(_searchQuery.isEmpty ? 'No products available' : 'No products found matching "$_searchQuery"'))
                  );
                }

                final double screenHeight = MediaQuery.of(context).size.height;
                final double screenWidth = MediaQuery.of(context).size.width;
                double ratio = 0.46; 
                if (screenWidth / screenHeight > 0.5) {
                  ratio = 0.52;
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: ratio,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildProductCard(context, products[index]),
                      childCount: products.length,
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentIndex = 0;
  int _itemCount = 0;
  final Color primaryColor = const Color(0xFFB10044);
  late final Stream<QuerySnapshot> _bannersStream;
  late final PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _bannersStream = FirebaseFirestore.instance.collection('banners').orderBy('createdAt', descending: true).snapshots();
    
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && _itemCount > 1) {
        int nextIndex = (_currentIndex + 1) % _itemCount;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _bannersStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final banners = snapshot.data!.docs;
        
        // Update item count for auto-scroll logic
        if (_itemCount != banners.length) {
          _itemCount = banners.length;
          // Note: We could restart timer here if needed
        }

        return Column(
          children: [
            SizedBox(
              height: 210,
              child: PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final data = banners[index].data() as Map<String, dynamic>;
                  final imageUrl = data['imageUrl'] ?? '';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? primaryColor : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
