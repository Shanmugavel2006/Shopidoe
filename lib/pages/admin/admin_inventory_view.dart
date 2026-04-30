import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import 'admin_add_product_view.dart';

class AdminInventoryView extends StatefulWidget {
  const AdminInventoryView({super.key});

  @override
  State<AdminInventoryView> createState() => _AdminInventoryViewState();
}

class _AdminInventoryViewState extends State<AdminInventoryView> {
  final Color primaryColor = const Color(0xFFB10044);
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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

  Widget _buildInventoryItem(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: product.imageUrl.isNotEmpty 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(product.imageUrl, fit: BoxFit.cover),
                )
              : const Icon(Icons.image_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8)),
                      child: Text(product.category.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
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
                          icon: Icon(Icons.edit_outlined, size: 18, color: primaryColor),
                        ),
                        IconButton(
                          onPressed: () => _deleteProduct(product.id),
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        ),
                        Text('#${product.id.substring(0, 5)}', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (product.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.description, 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 4),
                Text('₹ ${product.price}', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Switch(
                          value: product.isAvailable, 
                          onChanged: (v) async {
                            await FirebaseFirestore.instance.collection('products').doc(product.id).update({'isAvailable': v});
                          }, 
                          activeColor: primaryColor,
                        ),
                        Text('AVAILABLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Inventory Control',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
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
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Colors.grey[400]),
                      hintText: 'Search products, categories...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.filter_list, color: primaryColor),
            ],
          ),
        ),
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

              // Apply search
              if (_searchQuery.isNotEmpty) {
                products = products.where((p) => 
                  p.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                  p.category.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();
              }

              if (products.isEmpty) {
                return Center(child: Text(_searchQuery.isEmpty ? 'No products in inventory' : 'No matching products found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: products.length,
                itemBuilder: (context, index) => _buildInventoryItem(products[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
