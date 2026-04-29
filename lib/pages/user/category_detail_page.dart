import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import 'checkout_page.dart';

class CategoryDetailPage extends StatelessWidget {
  final String categoryName;
  final VoidCallback onBack;
  const CategoryDetailPage({super.key, required this.categoryName, required this.onBack});

  final Color primaryColor = const Color(0xFFB10044);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: onBack,
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
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.black87)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              categoryName.toUpperCase(),
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
                  .where('category', isEqualTo: categoryName)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final products = snapshot.data!.docs.map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>)).toList();

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No products in $categoryName', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.42,
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
                            ],
                          ),
                        ),
                      );
                    }
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Buy Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () {
                        CartService.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to Cart'), duration: Duration(seconds: 1)),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Add to Cart',
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
