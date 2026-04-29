import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  final Color primaryColor = const Color(0xFFB10044);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('My Wishlist', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Your wishlist is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final items = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              onPressed: () => CartService.toggleWishlist(item),
                              icon: const Icon(Icons.favorite, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(item.category, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('₹${item.price}', style: TextStyle(fontWeight: FontWeight.w900, color: primaryColor)),
                              GestureDetector(
                                onTap: () => CartService.addToCart(item),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                                  child: Icon(Icons.add_shopping_cart, size: 16, color: primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ],
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
