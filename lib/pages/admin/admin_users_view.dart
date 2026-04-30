import 'package:flutter/material.dart';
import 'admin_user_profile_view.dart';

class AdminUsersView extends StatelessWidget {
  const AdminUsersView({super.key});

  Widget _buildUserCard(BuildContext context, String name, String phone, String address, String email, String initial) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: const Color(0xFFB10044).withOpacity(0.1), child: Text(initial, style: const TextStyle(color: Color(0xFFB10044), fontWeight: FontWeight.bold))),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(phone, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text(address, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(onPressed: () {}, icon: const Icon(Icons.do_not_disturb_on_outlined, color: Colors.red, size: 18), label: const Text('Deactivate', style: TextStyle(color: Colors.red))),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminUserProfileView(
                        userName: name,
                        userPhone: phone,
                        userAddress: address,
                        userEmail: email,
                      ),
                    ),
                  );
                }, 
                icon: const Icon(Icons.info_outline, color: Color(0xFFB10044), size: 18), 
                label: const Text('Details', style: TextStyle(color: Color(0xFFB10044)))),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Registered Users',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 8),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFB10044), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 32),
        _buildUserCard(context, 'saranraja', '9003892505', 'Omalur,Salem-12', 'shanmugavelraja35@gmail.com', 'S'),
        _buildUserCard(context, 'Varshini', '9489858669', 'vkl', 'varshini@example.com', 'V'),
      ],
    );
  }
}
