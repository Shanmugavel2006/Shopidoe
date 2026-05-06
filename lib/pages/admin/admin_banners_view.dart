import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/cloudinary_service.dart';

class AdminBannersView extends StatefulWidget {
  const AdminBannersView({super.key});

  @override
  State<AdminBannersView> createState() => _AdminBannersViewState();
}

class _AdminBannersViewState extends State<AdminBannersView> {
  final Color primaryColor = const Color(0xFFB10044);
  bool _isUploading = false;

  Future<void> _pickAndUploadBanner() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() => _isUploading = true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading banner...')),
        );
      }

      final url = await CloudinaryService.uploadImage(File(pickedFile.path));
      if (url != null) {
        await FirebaseFirestore.instance.collection('banners').add({
          'imageUrl': url,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Banner added successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload banner.')),
          );
        }
      }
      
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _deleteBanner(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Banner'),
        content: const Text('Are you sure you want to delete this banner?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('banners').doc(id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Banners',
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: Theme.of(context).textTheme.bodyLarge?.color
                ),
              ),
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 32),
              
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('banners')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text('Failed to load banners. Check database rules or indexes.'));
                    }

                    final banners = snapshot.data?.docs ?? [];

                    if (banners.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.collections_outlined, size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No banners active', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
                      color: primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100), // Space for bottom button
                        itemCount: banners.length,
                        itemBuilder: (context, index) {
                          final banner = banners[index];
                          final data = banner.data() as Map<String, dynamic>;
                          final imageUrl = data['imageUrl'] ?? '';
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: double.infinity,
                                      height: 180,
                                      color: Colors.grey[200],
                                      child: const Center(child: CircularProgressIndicator()),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      width: double.infinity,
                                      height: 180,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Banner #${banner.id.substring(0, 5).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _deleteBanner(banner.id),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Add Banner Button at bottom center
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 200,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadBanner,
                icon: _isUploading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.add_photo_alternate, color: Colors.white),
                label: Text(
                  _isUploading ? 'Uploading...' : 'Add Banner',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 8,
                  shadowColor: primaryColor.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
