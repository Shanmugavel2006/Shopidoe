import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import 'checkout_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final Color primaryColor = const Color(0xFFB10044);
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  bool _isZoomed = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // We consider variants as images for the carousel if they have images, 
  // plus the main product image.
  List<String> get _productImages {
    List<String> images = [];
    if (widget.product.imageUrl.isNotEmpty) {
      images.add(widget.product.imageUrl);
    }
    for (var variant in widget.product.variants) {
      if (variant['imageUrl'] != null && (variant['imageUrl'] as String).isNotEmpty) {
        images.add(variant['imageUrl'] as String);
      }
    }
    return images.isEmpty ? [] : images.toSet().toList();
  }

  void _showWriteReviewBottomSheet() {
    double _rating = 5;
    final TextEditingController _commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Write a Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Tap a star to rate:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                        onPressed: () {
                          setModalState(() {
                            _rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Share your experience with this product...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryColor, width: 2), borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_commentController.text.trim().isEmpty) return;
                        
                        final user = FirebaseAuth.instance.currentUser;
                        String userName = 'Anonymous';
                        if (user != null) {
                           final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                           if (userDoc.exists) userName = userDoc.data()?['name'] ?? 'Anonymous';
                        }
                        
                        await FirebaseFirestore.instance.collection('reviews').add({
                          'productId': widget.product.id,
                          'productName': widget.product.name,
                          'userId': user?.uid ?? 'unknown',
                          'userName': userName,
                          'rating': _rating,
                          'comment': _commentController.text.trim(),
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                        
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted!')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Submit Review', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  void _showVariantPicker({required bool buyNow}) {
    if (widget.product.variants.isEmpty) {
      if (buyNow) {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => CheckoutPage(items: [widget.product], isSingleProduct: true),
        ));
      } else {
        CartService.addToCart(widget.product);
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
                  itemCount: widget.product.variants.length,
                  itemBuilder: (context, index) {
                    final v = widget.product.variants[index];
                    final isAvailable = v['isAvailable'] == true;
                    final variantProduct = Product(
                      id: '${widget.product.id}_${v['name']}',
                      name: '${widget.product.name} - ${v['name'] ?? ''}',
                      category: widget.product.category,
                      price: v['price'] ?? widget.product.price,
                      status: isAvailable ? 'In Stock' : 'Out of Stock',
                      isAvailable: isAvailable,
                      imageUrl: (v['imageUrl'] != null && (v['imageUrl'] as String).isNotEmpty)
                          ? v['imageUrl'] : widget.product.imageUrl,
                      description: widget.product.description,
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
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 80, height: 80,
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
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(v['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 8),
                                    Text('₹${v['price'] ?? widget.product.price}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 18)),
                                    const SizedBox(height: 8),
                                    if (!isAvailable)
                                      const Text('Sold Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
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

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 18);
        } else if (index < rating && rating % 1 != 0) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 18);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 18);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final images = _productImages;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Image Section
            Container(
              height: 350,
              width: double.infinity,
              color: Colors.white,
              child: Stack(
                children: [
                  if (images.isNotEmpty)
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      physics: _isZoomed ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                      onPageChanged: (index) => setState(() => _currentImageIndex = index),
                      itemBuilder: (context, index) {
                        return InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 4.0,
                          onInteractionStart: (_) => setState(() => _isZoomed = true),
                          onInteractionEnd: (details) {
                             // onInteractionEnd doesn't have scale, so we check the matrix 
                             // if we really need to, but for now we just rely on onInteractionUpdate 
                             // if we had a TransformationController.
                             // For simplicity, we can reset if pointerCount is 0.
                             if (details.pointerCount == 0) {
                               setState(() => _isZoomed = false);
                             }
                          },
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullScreenImageViewer(
                                    images: images,
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: 'product_image_$index',
                              child: CachedNetworkImage(
                                imageUrl: images[index],
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 50),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Center(child: Icon(Icons.image_outlined, size: 100, color: Colors.grey[300])),
                  
                  // Top buttons
                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        StreamBuilder<bool>(
                          stream: CartService.isInWishlist(widget.product.id),
                          builder: (context, snapshot) {
                            final isWishlisted = snapshot.data ?? false;
                            return CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: Icon(isWishlisted ? Icons.favorite : Icons.favorite_border, color: isWishlisted ? primaryColor : Colors.black),
                                onPressed: () {
                                  CartService.toggleWishlist(widget.product);
                                },
                              ),
                            );
                          }
                        ),
                        const SizedBox(height: 12),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.share_outlined, color: Colors.black),
                            onPressed: () {
                              final String shareText = 'Check out ${widget.product.name} for ₹${widget.product.price} at Shopidoe App!\n\nhttps://shopidoe.app/product/${widget.product.id}';
                              Share.share(shareText);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Carousel arrows
                  if (images.length > 1) ...[
                    Positioned(
                      left: 16,
                      top: 150,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.black),
                          onPressed: () {
                            if (_currentImageIndex > 0) {
                              _pageController.animateToPage(
                                _currentImageIndex - 1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 150,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.black),
                          onPressed: () {
                            if (_currentImageIndex < images.length - 1) {
                              _pageController.animateToPage(
                                _currentImageIndex + 1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${widget.product.price}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primaryColor),
                    ),
                    if (widget.product.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        widget.product.description,
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Reviews Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reviews & Ratings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        TextButton(
                          onPressed: _showWriteReviewBottomSheet,
                          child: Text('Write Review', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('reviews').where('productId', isEqualTo: widget.product.id).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return Text('Error loading reviews: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        
                        final reviewDocs = snapshot.data!.docs;
                        
                        // Sort locally to avoid needing a composite index in Firestore
                        final reviews = reviewDocs.toList()
                          ..sort((a, b) {
                            final aData = a.data() as Map<String, dynamic>;
                            final bData = b.data() as Map<String, dynamic>;
                            final aTime = aData['createdAt'] as Timestamp?;
                            final bTime = bData['createdAt'] as Timestamp?;
                            if (aTime == null && bTime == null) return 0;
                            if (aTime == null) return 1;
                            if (bTime == null) return -1;
                            return bTime.compareTo(aTime); // descending
                          });
                        
                        double averageRating = 0;
                        if (reviews.isNotEmpty) {
                          averageRating = reviews.map((e) {
                            final data = e.data() as Map<String, dynamic>;
                            return (data['rating'] as num?)?.toDouble() ?? 0.0;
                          }).reduce((a, b) => a + b) / reviews.length;
                        }
                        
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: primaryColor.withOpacity(0.1)),
                              ),
                              child: Column(
                                children: [
                                  Text(averageRating.toStringAsFixed(1), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                                  const SizedBox(height: 8),
                                  _buildStarRating(averageRating),
                                  const SizedBox(height: 4),
                                  Text('${reviews.length} reviews', style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (reviews.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No reviews yet. Be the first to review!', style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: reviews.length,
                                itemBuilder: (context, index) {
                                  final review = reviews[index].data() as Map<String, dynamic>;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2D3243),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(review['userName'] ?? 'Anonymous', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                                            _buildStarRating((review['rating'] as num).toDouble()),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(review['comment'] ?? '', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    Text('Related', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 16),
                    // Related section can just be a placeholder or simple stream builder
                    SizedBox(
                      height: 150,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('products')
                            .where('category', isEqualTo: widget.product.category)
                            .limit(40) // Fetch a larger batch for better matching in memory
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          
                          final allDocs = snapshot.data!.docs;
                          final List<Product> allRelated = allDocs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return Product.fromMap({...data, 'id': doc.id});
                          }).toList();
                          
                          // Keywords to ignore
                          final ignoreWords = {'the', 'and', 'for', 'with', 'natural', 'pure', 'best', 'organic', 'product'};
                          
                          // Extract significant words from current product name
                          final currentName = widget.product.name.toLowerCase();
                          final currentWords = currentName
                              .split(RegExp(r'[\s\-,.]+'))
                              .where((w) => w.length > 2 && !ignoreWords.contains(w))
                              .toList();

                          // Algorithm: Calculate relevance score for each product
                          final scoredProducts = allRelated
                              .where((p) => p.id != widget.product.id)
                              .map((p) {
                                final pName = p.name.toLowerCase();
                                double score = 0;

                                // 1. Check for word matches (fuzzy)
                                for (var word in currentWords) {
                                  if (pName.contains(word)) {
                                    score += 10;
                                    // Bonus for exact word match
                                    if (pName.split(RegExp(r'\s+')).contains(word)) {
                                      score += 5;
                                    }
                                  }
                                }

                                // 2. Bonus if they start with the same brand/word
                                final currentFirstWord = currentName.split(' ').first;
                                if (pName.startsWith(currentFirstWord) && currentFirstWord.length > 2) {
                                  score += 15;
                                }

                                // 3. Small bonus for similar price range (within 20%)
                                try {
                                  double p1 = double.parse(widget.product.price.replaceAll(',', ''));
                                  double p2 = double.parse(p.price.replaceAll(',', ''));
                                  if ((p1 - p2).abs() < (p1 * 0.2)) {
                                    score += 2;
                                  }
                                } catch (_) {}

                                return MapEntry(p, score);
                              })
                              .toList();

                          // Sort by score (descending)
                          scoredProducts.sort((a, b) => b.value.compareTo(a.value));
                          
                          // Group by score to allow shuffling among equally relevant items
                          final Map<double, List<Product>> grouped = {};
                          for (var entry in scoredProducts) {
                            grouped.putIfAbsent(entry.value, () => []).add(entry.key);
                          }

                          final List<Product> finalFive = [];
                          final sortedScores = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

                          for (var score in sortedScores) {
                            final group = grouped[score]!..shuffle();
                            for (var item in group) {
                              if (finalFive.length < 5) finalFive.add(item);
                              else break;
                            }
                            if (finalFive.length >= 5) break;
                          }

                          if (finalFive.isEmpty) {
                            return const Center(child: Text('No related products found', style: TextStyle(color: Colors.grey, fontSize: 12)));
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: finalFive.length,
                            itemBuilder: (context, index) {
                              final p = finalFive[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => ProductDetailsPage(product: p)),
                                  );
                                },
                                child: Container(
                                  width: 120,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                          child: p.imageUrl.isNotEmpty 
                                            ? CachedNetworkImage(
                                                imageUrl: p.imageUrl,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                placeholder: (context, url) => Container(color: Colors.grey[100]),
                                                errorWidget: (context, url, error) => const Center(child: Icon(Icons.image_not_supported)),
                                              )
                                            : Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.image))),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p.name, 
                                              maxLines: 1, 
                                              overflow: TextOverflow.ellipsis, 
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)
                                            ),
                                            Text(
                                              '₹${p.price}', 
                                              style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold)
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 80), // Padding for bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _showVariantPicker(buyNow: false),
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              label: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _controller;
  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;
  bool _canScroll = true;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
      setState(() => _canScroll = true);
    } else {
      final position = _doubleTapDetails!.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 1.5, -position.dy * 1.5)
        ..scale(2.5);
      setState(() => _canScroll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            physics: _canScroll ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return GestureDetector(
                onDoubleTapDown: (details) => _doubleTapDetails = details,
                onDoubleTap: _handleDoubleTap,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  onInteractionStart: (_) => setState(() => _canScroll = false),
                  onInteractionEnd: (details) {
                    if (_transformationController.value.getMaxScaleOnAxis() <= 1.0) {
                      setState(() => _canScroll = true);
                    }
                  },
                  child: Center(
                    child: Hero(
                      tag: 'product_image_$index',
                      child: CachedNetworkImage(
                        imageUrl: widget.images[index],
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                        errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.white, size: 50),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Double tap or pinch to zoom',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _transformationController.dispose();
    super.dispose();
  }
}
