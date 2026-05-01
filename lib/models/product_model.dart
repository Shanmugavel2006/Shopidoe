class Product {
  final String id;
  final String name;
  final String category;
  final String price;
  final String status;
  final bool isAvailable;
  final String imageUrl;
  final String description;
  final List<Map<String, dynamic>> variants;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.status,
    required this.isAvailable,
    required this.imageUrl,
    this.description = '',
    this.variants = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'status': status,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'description': description,
      'variants': variants,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: map['price'] ?? '',
      status: map['status'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      variants: List<Map<String, dynamic>>.from(
        (map['variants'] ?? []).map((v) => Map<String, dynamic>.from(v)),
      ),
    );
  }
}
