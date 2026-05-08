import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../services/speech_service.dart';
import '../../services/search_suggestion_service.dart';
import 'admin_add_product_view.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AdminInventoryView extends StatefulWidget {
  const AdminInventoryView({super.key});

  @override
  State<AdminInventoryView> createState() => _AdminInventoryViewState();
}

class _AdminInventoryViewState extends State<AdminInventoryView> with SpeechRecognitionMixin<AdminInventoryView> {
  final Color primaryColor = const Color(0xFFB10044);
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<String> _productNames = [];
  bool _showSuggestions = true;

  @override
  void initState() {
    super.initState();
    initSpeech();
    _fetchProductNames();
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

  void _listen() {
    toggleListening(
      controller: _searchController,
      onResult: (text) => setState(() => _searchQuery = text),
    );
  }

  void _showManageCategoriesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Manage Categories', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('categories').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final categories = snapshot.data!.docs;
              
              if (categories.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No categories found.'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return ListTile(
                    title: Text(cat['name']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Category?'),
                            content: Text('Are you sure you want to delete "${cat['name']}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await FirebaseFirestore.instance.collection('categories').doc(cat.id).delete();
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('products').doc(id).delete();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showVariantsDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.layers_outlined, color: primaryColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Variants for ${product.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (product.variants.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('No variants added for this product.', style: TextStyle(color: Colors.grey[500])),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 350),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: product.variants.length,
                    itemBuilder: (context, index) {
                      final v = product.variants[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: primaryColor.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(color: primaryColor.withOpacity(0.04), blurRadius: 8),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Variant Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 56,
                                height: 56,
                                color: Colors.grey[100],
                                child: (v['imageUrl'] != null && (v['imageUrl'] as String).isNotEmpty)
                                    ? CachedNetworkImage(
                                        imageUrl: v['imageUrl'],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(color: Colors.grey[100]),
                                        errorWidget: (context, url, error) => Icon(Icons.image_outlined, color: Colors.grey[400]),
                                      )
                                    : Icon(Icons.image_outlined, color: Colors.grey[400]),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(v['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('₹ ${v['price'] ?? ''}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale: 0.7,
                                        child: SizedBox(
                                          width: 40,
                                          child: Switch(
                                            value: v['isAvailable'] == true,
                                            onChanged: (val) async {
                                              setDialogState(() {
                                                product.variants[index]['isAvailable'] = val;
                                              });
                                              await FirebaseFirestore.instance.collection('products').doc(product.id).update({'variants': product.variants});
                                            },
                                            activeColor: primaryColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        (v['isAvailable'] == true) ? 'AVAILABLE' : 'OUT OF STOCK',
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(Icons.edit_outlined, size: 18, color: primaryColor),
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Scaffold(
                                          appBar: AppBar(
                                            backgroundColor: Colors.white,
                                            elevation: 0,
                                            iconTheme: IconThemeData(color: primaryColor),
                                            title: Text('Edit Product', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold)),
                                          ),
                                          body: AdminAddProductView(product: product),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Variant?'),
                                        content: const Text('Are you sure you want to delete this variant?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      setDialogState(() {
                                        product.variants.removeAt(index);
                                      });
                                      await FirebaseFirestore.instance.collection('products').doc(product.id).update({'variants': product.variants});
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildInventoryItem(Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100], 
              borderRadius: BorderRadius.circular(12)
            ),
            child: product.imageUrl.isNotEmpty 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: isDark ? Colors.grey[900] : Colors.grey[100]),
                    errorWidget: (context, url, error) => const Icon(Icons.image_outlined, color: Colors.grey),
                  ),
                )
              : const Icon(Icons.image_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          // Content Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category and Action Buttons
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: primaryColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          product.category.toUpperCase(), 
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action Buttons Row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
                                  appBar: AppBar(
                                    backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                    elevation: 0,
                                    iconTheme: IconThemeData(color: primaryColor),
                                    title: Text('Edit Product', style: TextStyle(color: isDark ? Colors.white : Colors.grey[800], fontWeight: FontWeight.bold)),
                                  ),
                                  body: AdminAddProductView(product: product),
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.edit_outlined, size: 18, color: primaryColor),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _deleteProduct(product.id),
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Product Name
                Text(
                  product.name, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87
                  )
                ),
                // Product Description or ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (product.description.isNotEmpty)
                      Expanded(
                        child: Text(
                          product.description, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
                        ),
                      )
                    else
                      const Spacer(),
                    Text('#${product.id.substring(0, 5)}', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                  ],
                ),
                const SizedBox(height: 4),
                Text('₹ ${product.price}', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 16)),
                const SizedBox(height: 8),
                // Variants Tag
                if (product.variants.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showVariantsDialog(product),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.layers_outlined, color: primaryColor, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            '${product.variants.length} Variants – View',
                            style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Availability Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      product.isAvailable ? 'AVAILABLE' : 'OUT OF STOCK', 
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: product.isAvailable ? primaryColor : Colors.grey)
                    ),
                    const SizedBox(width: 4),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: product.isAvailable, 
                        onChanged: (v) async {
                          await FirebaseFirestore.instance.collection('products').doc(product.id).update({'isAvailable': v});
                        }, 
                        activeColor: primaryColor,
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
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inventory Control',
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A)
                ),
              ),
              IconButton(
                onPressed: _showManageCategoriesDialog,
                icon: Icon(Icons.category_outlined, color: primaryColor),
                tooltip: 'Manage Categories',
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Audit and update your product availability.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    onChanged: (v) {
                      setState(() {
                        _searchQuery = v;
                        _showSuggestions = true;
                      });
                    },
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Colors.grey[400]),
                      hintText: 'Search products, categories...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(isListening ? Icons.mic : Icons.mic_none, color: primaryColor),
                        onPressed: _listen,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.filter_list, color: primaryColor),
            ],
          ),
        ),
        if (_searchQuery.isNotEmpty && _showSuggestions) ...[
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
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
            child: SingleChildScrollView(
              child: Column(
                children: SearchSuggestionService.getFilteredSuggestions(_searchQuery, _productNames.isNotEmpty ? _productNames : SearchSuggestionService.adminInventorySuggestions)
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
        const SizedBox(height: 32),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text('Error loading products'));
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

              List<Product> products = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Product.fromMap(data);
              }).toList();

              products.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

              if (_searchQuery.isNotEmpty) {
                products = products.where((p) => 
                  p.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                  p.category.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();
              }

              if (products.isEmpty) {
                return Center(
                  child: Text(
                    _searchQuery.isEmpty ? 'No products in inventory' : 'No matching products found',
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  )
                );
              }

              return RefreshIndicator(
                onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
                color: primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: products.length,
                  itemBuilder: (context, index) => _buildInventoryItem(products[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
