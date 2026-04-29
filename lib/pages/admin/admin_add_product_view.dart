import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/cloudinary_service.dart';
import '../../models/product_model.dart';

class AdminAddProductView extends StatefulWidget {
  const AdminAddProductView({super.key});

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
  final TextEditingController _tagController = TextEditingController();

  File? _pickedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
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
      final docRef = FirebaseFirestore.instance.collection('products').doc();
      final product = Product(
        id: docRef.id,
        name: _nameController.text,
        category: _categoryController.text,
        price: _priceController.text,
        status: _isInStock ? 'In Stock' : 'Out of Stock',
        isAvailable: _isInStock,
        imageUrl: _uploadedImageUrl!,
      );

      await docRef.set(product.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        _clearForm();
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
    _tagController.clear();
    setState(() {
      _pickedImage = null;
      _uploadedImageUrl = null;
      _variants.clear();
      _isInStock = true;
    });
  }

  void _showAddVariantDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool variantInStock = true;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Add Product Variant', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Variant Name (e.g. Red, 500g)', 'e.g. Small, Large'),
                  const SizedBox(height: 16),
                  _buildTextField('Price', '0.00', isNumber: true),
                  const SizedBox(height: 24),
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
                  setState(() {
                    _variants.add({'name': 'New Variant', 'price': '0.00'});
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blueGrey[800], letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Product',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 40),
          _buildTextField('Product Name', 'Enter product name...', controller: _nameController),
          const SizedBox(height: 32),
          _buildTextField('Price in Rupees', '0.00', isNumber: true, controller: _priceController),
          const SizedBox(height: 32),
          _buildTextField('Category Selection', 'e.g. Masala, Soap, Grocery', controller: _categoryController),
          const SizedBox(height: 32),
          
          Text(
            'PRODUCT IMAGE',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blueGrey[800], letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!, width: 1, style: BorderStyle.solid),
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
                            Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('Click to upload image', style: TextStyle(color: Colors.grey[400])),
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
              const Text(
                'Available in Stock:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
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
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blueGrey[800], letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          if (_variants.isNotEmpty) ...[
            ..._variants.map((v) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(v['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.close, size: 18, color: Colors.red)),
                ],
              ),
            )),
            const SizedBox(height: 16),
          ],
          OutlinedButton.icon(
            onPressed: _showAddVariantDialog,
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Add Multiple Options / Variants'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1A1A1A),
              side: const BorderSide(color: Color(0xFF1A1A1A)),
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
                  Text(_isSaving ? 'Saving...' : (_isUploading ? 'Uploading...' : 'Add Product'), 
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
