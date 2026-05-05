import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import 'checkout_page.dart';
import 'product_details_page.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryName;
  final VoidCallback onBack;
  const CategoryDetailPage({super.key, required this.categoryName, required this.onBack});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final Color primaryColor = const Color(0xFFB10044);
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('onStatus: $val'),
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _searchController.text = val.recognizedWords;
            _searchQuery = val.recognizedWords;
          }),
        );
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        color: isAvailable ? Colors.white : Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isAvailable ? primaryColor.withOpacity(0.3) : Colors.grey[200]!),
                        boxShadow: isAvailable ? [
                           BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
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
                                        ? Image.network(variantProduct.imageUrl, fit: BoxFit.cover)
                                        : Icon(Icons.image_outlined, color: Colors.grey[400], size: 40),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: widget.onBack,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 24,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.shopping_bag, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              'Shopidoe',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          IconButton(
            onPressed: () => setState(() => _isSearchExpanded = !_isSearchExpanded),
            icon: Icon(_isSearchExpanded ? Icons.close : Icons.search, color: Colors.black87)
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isSearchExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor, width: 1.5),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search ${widget.categoryName}...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: IconButton(
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: primaryColor),
                      onPressed: _listen,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Text(
              widget.categoryName.toUpperCase(),
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: primaryColor,
                letterSpacing: 2,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('category', isEqualTo: widget.categoryName)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                var products = snapshot.data!.docs.map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>)).toList();
                products.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                
                if (_searchQuery.isNotEmpty) {
                  products = products.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                }

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No products in ${widget.categoryName}', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: (MediaQuery.of(context).size.width / MediaQuery.of(context).size.height) > 0.5 ? 0.6 : 0.48,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(context, products[index], 'TOP PICK');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, String tag) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ProductDetailsPage(product: product),
                    ));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    width: double.infinity,
                    child: Center(
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.image_outlined, size: 50, color: Colors.grey[300]),
                            )
                          : Icon(Icons.image_outlined, size: 50, color: Colors.grey[300]),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.status,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: primaryColor),
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
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? primaryColor : Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tag,
                    style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.price}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                      child: ElevatedButton(
                        onPressed: () => _showVariantPicker(context, product, buyNow: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          product.variants.isNotEmpty ? 'Buy Now ▾' : 'Buy Now',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () => _showVariantPicker(context, product, buyNow: false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          product.variants.isNotEmpty ? 'Add to Cart ▾' : 'Add to Cart',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
