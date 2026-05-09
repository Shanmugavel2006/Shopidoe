import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:confetti/confetti.dart';
import '../../models/product_model.dart';
import 'user_home_page.dart';
import 'package:intl/intl.dart';

class OrderSuccessPage extends StatefulWidget {
  final List<Product> items;
  final String paymentMethod;
  final String address;
  final String userName;
  final String mobile;

  const OrderSuccessPage({
    super.key,
    required this.items,
    required this.paymentMethod,
    required this.address,
    required this.userName,
    required this.mobile,
  });

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage>
    with TickerProviderStateMixin {
  final Color primaryColor = const Color(0xFFB10044);

  // Confetti controllers — left, center, right for a full blast effect
  late ConfettiController _leftController;
  late ConfettiController _centerController;
  late ConfettiController _rightController;

  // Pulse animation for the success icon
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Slide-up animation for content
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Confetti — fire from 3 positions for a fireworks burst feel
    _leftController = ConfettiController(duration: const Duration(seconds: 4));
    _centerController = ConfettiController(duration: const Duration(seconds: 5));
    _rightController = ConfettiController(duration: const Duration(seconds: 4));

    // Pulse animation for success icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Slide-up + fade animation for content
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeIn),
    );

    // Start all animations on load
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _leftController.play();
      _centerController.play();
      _rightController.play();
    });
  }

  @override
  void dispose() {
    _leftController.dispose();
    _centerController.dispose();
    _rightController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in widget.items) {
      total += double.parse(item.price.replaceAll(',', ''));
    }
    return total;
  }

  Path _drawStar(Size size) {
    final path = Path();
    const numPoints = 5;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < numPoints * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (pi / numPoints) * i - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void _showOrderDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Order Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PRODUCTS ORDERED', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 12),
                    ...widget.items.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              width: 80, height: 80, fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Theme.of(context).cardColor),
                              errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('₹${item.price}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 24),
                    const Text('CUSTOMER DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${widget.userName}', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('Mobile: ${widget.mobile}', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('Address: ${widget.address}', style: const TextStyle(fontSize: 14, height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('PAYMENT DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Method:', style: TextStyle(fontSize: 14)),
                              Text(widget.paymentMethod.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Paid:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('₹${_calculateTotal().toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('MMMM dd, yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Shopidoe', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // ── Main scrollable content ──
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ── Pulsing success icon ──
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [primaryColor.withOpacity(0.25), primaryColor.withOpacity(0.05)],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
                        ),
                        child: Icon(Icons.check_circle_rounded, size: 72, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Congratulations text ──
                    Text(
                      '🎉 Congratulations!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your Order is Placed\nSuccessfully!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.3),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Thank you for shopping with Shopidoe Boutique.\nYou\'ll receive a confirmation shortly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 36),

                    // ── Order details card ──
                    _buildInfoCard(context, 'ORDER DETAILS',
                      Row(
                        children: [
                          _buildInfoItem('Date', dateStr),
                          const Spacer(),
                          _buildInfoItem('Time', timeStr, isRight: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Delivery address card ──
                    _buildInfoCard(context, 'DELIVERY ADDRESS',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(widget.mobile, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 12),
                          Text(widget.address, style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Order summary (pink card) ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ORDER SUMMARY', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(height: 16),
                          const Text('Total Amount Paid', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('₹${_calculateTotal().toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                            child: Text('PAID VIA ${widget.paymentMethod.toUpperCase()}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Buttons ──
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _showOrderDetails(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : const Color(0xFF1A1A1A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('View Order Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          // Replay confetti
                          _centerController.play();
                          _leftController.play();
                          _rightController.play();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('🎊 Celebrate Again!', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const UserHomePage()),
                          (route) => false,
                        );
                      },
                      child: const Text('Back to Home', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // ── Confetti — Left cannon ──
          Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _leftController,
              blastDirection: -pi / 4,     // upper-right diagonal
              emissionFrequency: 0.06,
              numberOfParticles: 18,
              maxBlastForce: 40,
              minBlastForce: 20,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                Color(0xFFB10044), Color(0xFFFF6B6B), Color(0xFFFFD93D),
                Color(0xFF6BCB77), Color(0xFF4D96FF), Color(0xFFFF922B),
                Color(0xFFCC5DE8), Color(0xFFFF8ED4),
              ],
              createParticlePath: _drawStar,
            ),
          ),

          // ── Confetti — Center cannon (straight up) ──
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _centerController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.04,
              numberOfParticles: 25,
              maxBlastForce: 60,
              minBlastForce: 30,
              gravity: 0.25,
              shouldLoop: false,
              colors: const [
                Color(0xFFB10044), Color(0xFFFFD93D), Color(0xFF6BCB77),
                Color(0xFF4D96FF), Color(0xFFFF922B), Color(0xFFCC5DE8),
                Color(0xFFFF6B6B), Color(0xFFFFFFFF), Color(0xFFFF8ED4),
              ],
            ),
          ),

          // ── Confetti — Right cannon ──
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _rightController,
              blastDirection: pi + pi / 4,  // upper-left diagonal
              emissionFrequency: 0.06,
              numberOfParticles: 18,
              maxBlastForce: 40,
              minBlastForce: 20,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                Color(0xFFB10044), Color(0xFFFF6B6B), Color(0xFFFFD93D),
                Color(0xFF6BCB77), Color(0xFF4D96FF), Color(0xFFFF922B),
                Color(0xFFCC5DE8), Color(0xFFFF8ED4),
              ],
              createParticlePath: _drawStar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
