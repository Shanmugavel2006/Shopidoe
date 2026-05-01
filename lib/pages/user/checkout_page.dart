import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/product_model.dart';
import 'order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<Product> items;
  final bool isSingleProduct;

  const CheckoutPage({super.key, required this.items, this.isSingleProduct = false});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  bool _isLoading = false;
  String _selectedPayment = 'Credit/Debit Card';

  final Color primaryColor = const Color(0xFFB10044);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _nameController.text = doc.data()?['name'] ?? '';
          _mobileController.text = doc.data()?['mobile'] ?? '';
          _addressController.text = doc.data()?['address'] ?? '';
        });
      }
    }
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in widget.items) {
      total += double.parse(item.price.replaceAll(',', ''));
    }
    return total;
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final orderData = {
        'userId': user?.uid,
        'userName': _nameController.text,
        'mobile': _mobileController.text,
        'address': '${_addressController.text}, ${_cityController.text} - ${_zipController.text}',
        'items': widget.items.map((e) => e.toMap()).toList(),
        'totalAmount': _calculateTotal(),
        'paymentMethod': _selectedPayment,
        'status': 'Ordered',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSuccessPage(
              items: widget.items,
              paymentMethod: _selectedPayment,
              address: '${_addressController.text}, ${_cityController.text} - ${_zipController.text}',
              userName: _nameController.text,
              mobile: _mobileController.text,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Items Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ITEMS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text('${widget.items.length} ITEMS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Your Selection', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 20),
              ...widget.items.map((item) => _buildSelectionCard(item)),
              
              const SizedBox(height: 32),
              // Shipping Form
              const Text('SHIPPING DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 16),
              _buildTextField('Full Name', _nameController, Icons.person_outline),
              _buildTextField('Mobile Number', _mobileController, Icons.phone_outlined, keyboardType: TextInputType.phone),
              _buildTextField('Shipping Address', _addressController, Icons.home_outlined, maxLines: 2),
              Row(
                children: [
                  Expanded(child: _buildTextField('City', _cityController, Icons.location_city)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Zip Code', _zipController, Icons.pin_drop_outlined, keyboardType: TextInputType.number)),
                ],
              ),

              const SizedBox(height: 32),
              // Order Summary
              const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', '₹${_calculateTotal().toStringAsFixed(0)}'),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Delivery Fee', 'Free', isPink: true),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(color: Colors.grey),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('₹${_calculateTotal().toStringAsFixed(0)}', 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: primaryColor)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              // Payment Options
              const Text('Payment Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 16),
              _buildPaymentOption('Credit/Debit Card', 'Visa, Mastercard, RuPay', Icons.credit_card),
              _buildPaymentOption('UPI (Google Pay/PhonePe)', 'Instant bank transfer', Icons.account_balance_wallet_outlined),
              _buildPaymentOption('Cash on Delivery', 'Pay when you receive', Icons.payments_outlined),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Place Order & Pay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard(Product item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl.isNotEmpty ? item.imageUrl : 'https://via.placeholder.com/150',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('1 x ₹${item.price}', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ],
            ),
          ),
          Text('₹${item.price}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isPink = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(
          color: isPink ? primaryColor : Colors.black, 
          fontSize: 15, 
          fontWeight: isPink ? FontWeight.bold : FontWeight.w500
        )),
      ],
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, IconData icon) {
    bool isSelected = _selectedPayment == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? primaryColor : Colors.grey[100]!, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? primaryColor : Colors.grey[600]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? primaryColor : Colors.grey[300]!, width: 2),
              ),
              child: isSelected ? Icon(Icons.circle, size: 10, color: primaryColor) : const SizedBox(width: 10, height: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[100]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[100]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryColor)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}
