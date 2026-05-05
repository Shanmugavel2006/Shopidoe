import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReviewsView extends StatefulWidget {
  const AdminReviewsView({super.key});

  @override
  State<AdminReviewsView> createState() => _AdminReviewsViewState();
}

class _AdminReviewsViewState extends State<AdminReviewsView> {
  final Color primaryColor = const Color(0xFFB10044);

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (index < rating && rating % 1 != 0) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 16);
        }
      }),
    );
  }

  Future<void> _deleteReview(String reviewId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('reviews').doc(reviewId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            'Product Reviews',
            style: TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white : const Color(0xFF1A1A1A)
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Container(width: 40, height: 4, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reviews').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No reviews found',
                      style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 16),
                    ),
                  );
                }

                final reviews = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reviews.length,
                  separatorBuilder: (context, index) => Divider(height: 24, color: isDark ? Colors.grey[800] : Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final doc = reviews[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['productName'] ?? 'Unknown Product',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        data['userName'] ?? 'Anonymous',
                                        style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStarRating((data['rating'] as num?)?.toDouble() ?? 0),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                              onPressed: () => _deleteReview(doc.id),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['comment'] ?? '',
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                        ),
                        if (data['createdAt'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            (data['createdAt'] as Timestamp).toDate().toString().split('.')[0],
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                          ),
                        ]
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
