import 'package:flutter/material.dart';

class CategoryUtils {
  static IconData getIconForCategory(String name) {
    name = name.toLowerCase();
    if (name.contains('cosmetic')) return Icons.auto_awesome;
    if (name.contains('care')) return Icons.shield_outlined;
    if (name.contains('bath')) return Icons.bathtub_outlined;
    if (name.contains('hygiene')) return Icons.clean_hands_outlined;
    if (name.contains('fragrance') || name.contains('perfume')) return Icons.air;
    if (name.contains('clean')) return Icons.cleaning_services_outlined;
    if (name.contains('health') || name.contains('med')) return Icons.add_box_outlined;
    if (name.contains('access')) return Icons.shopping_bag_outlined;
    if (name.contains('puja')) return Icons.temple_hindu_outlined;
    if (name.contains('herb')) return Icons.eco_outlined;
    if (name.contains('food') || name.contains('grocery')) return Icons.restaurant;
    if (name.contains('stationery')) return Icons.edit_note;
    if (name.contains('elec')) return Icons.electrical_services;
    
    return Icons.category_outlined; // Default icon
  }

  static Color getColorForCategory(String name) {
    name = name.toLowerCase();
    if (name.contains('cosmetic')) return const Color(0xFFB10044);
    if (name.contains('care')) return Colors.blueGrey;
    if (name.contains('bath')) return Colors.blue;
    if (name.contains('hygiene')) return Colors.teal;
    if (name.contains('fragrance')) return Colors.indigo;
    if (name.contains('clean')) return Colors.brown;
    if (name.contains('health')) return Colors.red;
    if (name.contains('access')) return Colors.orange;
    if (name.contains('puja')) return Colors.deepOrange;
    if (name.contains('herb')) return Colors.green;
    
    return Colors.blueGrey; // Default color
  }
}
