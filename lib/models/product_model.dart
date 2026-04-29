class Product {
  final String id;
  final String name;
  final String category;
  final String price;
  final String status;
  final bool isAvailable;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.status,
    required this.isAvailable,
    required this.imageUrl,
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
    );
  }
}
