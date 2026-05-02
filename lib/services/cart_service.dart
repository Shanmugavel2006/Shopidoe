import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class CartService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  // Cart Operations
  static Future<void> addToCart(Product product) async {
    if (_uid == null) return;
    final docRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .doc(product.id);
    
    final doc = await docRef.get();
    if (doc.exists) {
      final currentQty = doc.data()?['quantity'] ?? 1;
      await docRef.update({'quantity': currentQty + 1});
    } else {
      await docRef.set(product.toMap());
    }
  }

  static Future<void> removeFromCart(String productId) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  static Future<void> updateQuantity(String productId, int newQuantity) async {
    if (_uid == null) return;
    if (newQuantity < 1) {
      await removeFromCart(productId);
      return;
    }
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .doc(productId)
        .update({'quantity': newQuantity});
  }

  static Stream<List<Product>> getCartItems() {
    if (_uid == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('cart')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList());
  }

  // Wishlist Operations
  static Future<void> toggleWishlist(Product product) async {
    if (_uid == null) return;
    final docRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('wishlist')
        .doc(product.id);
    
    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set(product.toMap());
    }
  }

  static Stream<List<Product>> getWishlistItems() {
    if (_uid == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList());
  }

  static Stream<bool> isInWishlist(String productId) {
    if (_uid == null) return Stream.value(false);
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('wishlist')
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}
