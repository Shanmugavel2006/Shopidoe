import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import 'checkout_page.dart';

class WishlistPage extends StatelessWidget {
  final VoidCallback onBack;
  const WishlistPage({super.key, required this.onBack});

  final Color primaryColor = const Color(0xFFB10044);

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
                        color: isAvailable ? Theme.of(context).cardColor : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[50]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isAvailable ? primaryColor.withOpacity(0.3) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[200]!)),
                        boxShadow: isAvailable ? [
                           BoxShadow(color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.04), blurRadius: 10, offset: const Offset(0, 4))
                        ] : [],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (variantProduct.imageUrl.isNotEmpty) {
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
                                                child: Image.network(variantProduct.imageUrl, fit: BoxFit.contain),
                                              ),
                                            ),
                                            Positioned(
                                              top: 40, right: 20,
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 100, height: 100,
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[100],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('My Wishlist', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<Product>>(
        stream: CartService.getWishlistItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: primaryColor.withOpacity(isDark ? 0.4 : 0.2)),
                  const SizedBox(height: 16),
                  Text('Your wishlist is empty', style: TextStyle(fontSize: 18, color: Colors.grey[isDark ? 600 : 400])),
                  const SizedBox(height: 8),
                  Text('Save your favourite items here!', style: TextStyle(fontSize: 13, color: Colors.grey[isDark ? 800 : 300])),
                ],
              ),
            );
          }

          final items = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    Expanded(
                      flex: 5,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Container(
                              width: double.infinity,
                              color: isDark ? Colors.grey[900] : Colors.grey[50],
                              child: item.imageUrl.isNotEmpty
                                  ? Image.network(item.imageUrl, fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Icon(Icons.image_outlined, size: 40, color: Colors.grey[300]))
                                  : Icon(Icons.image_outlined, size: 40, color: Colors.grey[300]),
                            ),
                          ),
                          // Remove from wishlist
                          Positioned(
                            top: 6, right: 6,
                            child: GestureDetector(
                              onTap: () => CartService.toggleWishlist(item),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                                child: Icon(Icons.favorite, color: primaryColor, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Info
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(item.category,
                                style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text('₹${item.price}',
                                style: TextStyle(fontWeight: FontWeight.w900, color: primaryColor, fontSize: 15)),
                            const SizedBox(height: 6),
                            // Add to Cart / Buy Now
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 30,
                                    child: ElevatedButton(
                                      onPressed: () => _showVariantPicker(context, item, buyNow: true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Text(
                                        item.variants.isNotEmpty ? 'Buy ▾' : 'Buy Now',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _showVariantPicker(context, item, buyNow: false),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.add_shopping_cart, size: 16, color: primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
