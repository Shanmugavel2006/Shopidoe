import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/cloudinary_service.dart';
import '../../models/product_model.dart';
import '../../services/category_utils.dart';

class AdminAddProductView extends StatefulWidget {
  final Product? product;
  const AdminAddProductView({super.key, this.product});

  @override
  State<AdminAddProductView> createState() => _AdminAddProductViewState();
}

class _AdminAddProductViewState extends State<AdminAddProductView> {
  final Color primaryColor = const Color(0xFFB10044);
  bool _isInStock = true;
  final List<Map<String, dynamic>> _variants = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  File? _pickedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price;
      _categoryController.text = widget.product!.category;
      _descriptionController.text = widget.product!.description;
      _uploadedImageUrl = widget.product!.imageUrl;
      _isInStock = widget.product!.isAvailable;
      if (widget.product!.variants.isNotEmpty) {
        _variants.addAll(widget.product!.variants);
      }
    }
    _categoryController.addListener(() {
      setState(() {}); // Update icon preview as user types
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
        _isUploading = true;
      });
      
      final url = await CloudinaryService.uploadImage(_pickedImage!);
      setState(() {
        _uploadedImageUrl = url;
        _isUploading = false;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a product image')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final bool isEditing = widget.product != null;
      final docRef = isEditing 
          ? FirebaseFirestore.instance.collection('products').doc(widget.product!.id)
          : FirebaseFirestore.instance.collection('products').doc();
      
      // Ensure category exists in categories collection if we want dynamic categories
      final categoryName = _categoryController.text.trim();
      final categorySnap = await FirebaseFirestore.instance
          .collection('categories')
          .where('name', isEqualTo: categoryName)
          .get();
      
      if (categorySnap.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('categories').add({
          'name': categoryName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final product = Product(
        id: docRef.id,
        name: _nameController.text,
        category: categoryName,
        price: _priceController.text,
        status: _isInStock ? 'In Stock' : 'Out of Stock',
        isAvailable: _isInStock,
        imageUrl: _uploadedImageUrl!,
        description: _descriptionController.text,
        variants: List<Map<String, dynamic>>.from(_variants),
      );

      await docRef.set(product.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Product updated successfully!' : 'Product added successfully!')),
        );
        if (isEditing) {
          Navigator.pop(context);
        } else {
          _clearForm();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _categoryController.clear();
    _descriptionController.clear();
    _tagController.clear();
    setState(() {
      _pickedImage = null;
      _uploadedImageUrl = null;
      _variants.clear();
      _isInStock = true;
    });
  }

  void _showAddVariantDialog() {
    final variantNameController = TextEditingController();
    final variantPriceController = TextEditingController();
    File? variantImage;
    String? variantImageUrl;
    bool variantInStock = true;
    bool isUploadingVariant = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('Add Product Variant', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Variant Name
                  TextField(
                    controller: variantNameController,
                    decoration: InputDecoration(
                      labelText: 'Variant Name',
                      hintText: 'e.g. 500g, Red, Large',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Variant Price
                  TextField(
                    controller: variantPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price (₹)',
                      hintText: '0.00',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Variant Image
                  GestureDetector(
                    onTap: () async {
                      final picked = await _picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setDialogState(() {
                          variantImage = File(picked.path);
                          isUploadingVariant = true;
                        });
                        final url = await CloudinaryService.uploadImage(variantImage!);
                        setDialogState(() {
                          variantImageUrl = url;
                          isUploadingVariant = false;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: isUploadingVariant
                          ? Center(child: CircularProgressIndicator(color: primaryColor))
                          : variantImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(variantImage!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[400], size: 28),
                                    const SizedBox(height: 4),
                                    Text('Tap to add variant image', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stock toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Available in Stock:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Switch(
                        value: variantInStock,
                        onChanged: (v) => setDialogState(() => variantInStock = v),
                        activeColor: primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (variantNameController.text.isEmpty || variantPriceController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter variant name and price')),
                    );
                    return;
                  }
                  setState(() {
                    _variants.add({
                      'name': variantNameController.text.trim(),
                      'price': variantPriceController.text.trim(),
                      'imageUrl': variantImageUrl ?? '',
                      'isAvailable': variantInStock,
                    });
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Option', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {bool isNumber = false, int maxLines = 1, TextEditingController? controller}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isDark ? Colors.grey[400] : Colors.blueGrey[800], letterSpacing: 1),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product != null ? 'Edit Product' : 'Add New Product',
            style: TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white : const Color(0xFF1A1A1A)
            ),
          ),
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 40),
          _buildTextField('Product Name', 'Enter product name...', controller: _nameController),
          const SizedBox(height: 32),
          _buildTextField('Price in Rupees', '0.00', isNumber: true, controller: _priceController),
          const SizedBox(height: 32),
          
          Text(
            'CATEGORY SELECTION',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isDark ? Colors.grey[400] : Colors.blueGrey[800], letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _categoryController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: 'e.g. Masala, Soap, Grocery',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: CategoryUtils.getColorForCategory(_categoryController.text).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CategoryUtils.getIconForCategory(_categoryController.text),
                  color: CategoryUtils.getColorForCategory(_categoryController.text),
                  size: 20,
                ),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'PRODUCT DESCRIPTION',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isDark ? Colors.grey[400] : const Color(0xFF8B4513), letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          _buildTextField('', 'Enter detailed description (e.g. Product brown color...)', maxLines: 3, controller: _descriptionController),
          const SizedBox(height: 32),
          
          Text(
            'PRODUCT IMAGE',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isDark ? Colors.grey[400] : Colors.blueGrey[800], letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!, width: 1, style: BorderStyle.solid),
              ),
              child: _isUploading
                  ? Center(child: CircularProgressIndicator(color: primaryColor))
                  : _pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_pickedImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey[500]),
                            const SizedBox(height: 8),
                            Text('Click to upload image', style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
            ),
          ),
          if (_uploadedImageUrl != null) ...[
            const SizedBox(height: 8),
            const Text('✅ Image uploaded successfully', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
          
          const SizedBox(height: 32),
          _buildTextField('Tag (Optional)', 'e.g. ORGANIC, BEST SELLER', controller: _tagController),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available in Stock:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
              ),
              Switch(
                value: _isInStock,
                onChanged: (v) => setState(() => _isInStock = v),
                activeColor: primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            'PRODUCT VARIANTS (OPTIONAL)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isDark ? Colors.grey[400] : Colors.blueGrey[800], letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          if (_variants.isNotEmpty) ...[
            ..._variants.asMap().entries.map((entry) {
              final i = entry.key;
              final v = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 50,
                        height: 50,
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        child: (v['imageUrl'] != null && v['imageUrl'].isNotEmpty)
                            ? Image.network(v['imageUrl'], fit: BoxFit.cover)
                            : Icon(Icons.image_outlined, color: Colors.grey[500]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v['name'] ?? '', 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)
                          ),
                          Text('₹ ${v['price'] ?? ''}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
                          Text((v['isAvailable'] == true) ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _variants.removeAt(i)),
                      icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: _showAddVariantDialog,
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Add Multiple Options / Variants'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: (_isUploading || _isSaving) ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isSaving ? 'Saving...' : (_isUploading ? 'Uploading...' : (widget.product != null ? 'Update Product' : 'Add Product')), 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(width: 8),
                  if (!_isUploading && !_isSaving) const Icon(Icons.add, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
