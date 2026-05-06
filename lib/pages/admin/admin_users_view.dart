import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../services/speech_service.dart';
import '../../services/search_suggestion_service.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> with SpeechRecognitionMixin<AdminUsersView> {
  final Color primaryColor = const Color(0xFFB10044);
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void _listen() {
    toggleListening(
      controller: _searchController,
      onResult: (text) => setState(() => _searchQuery = text),
    );
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> userData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('User Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black87), 
                    onPressed: () => Navigator.pop(context)
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow(context, Icons.person, 'Name', userData['name'] ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDetailRow(context, Icons.email, 'Email', userData['email'] ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDetailRow(context, Icons.phone, 'Mobile', userData['mobile'] ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDetailRow(context, Icons.location_on, 'Address', userData['address'] ?? 'N/A'),
              const SizedBox(height: 12),
              _buildDetailRow(context, Icons.admin_panel_settings, 'Role', (userData['role'] ?? 'user').toString().toUpperCase()),
              const SizedBox(height: 12),
              _buildDetailRow(context, Icons.access_time, 'Status', (userData['isActive'] ?? true) ? 'Active' : 'Deactivated'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold)),
              Text(
                value, 
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w600, 
                  color: isDark ? Colors.white : Colors.black87
                )
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _toggleUserStatus(String uid, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isActive': !currentStatus,
      });
    } catch (e) {
      debugPrint('Error updating user status: $e');
    }
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> userData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String name = userData['name'] ?? 'Unknown';
    final String phone = userData['mobile'] ?? 'N/A';
    final String address = userData['address'] ?? 'N/A';
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final bool isActive = userData['isActive'] ?? true;
    final String uid = userData['uid'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.1), 
                child: Text(initial, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name, 
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: isDark ? Colors.white : Colors.black87
                      )
                    ),
                    Text(phone, style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
              if (!isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Deactivated', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[50], 
              borderRadius: BorderRadius.circular(12)
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address, 
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])
                  )
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () => _toggleUserStatus(uid, isActive), 
                icon: Icon(isActive ? Icons.do_not_disturb_on_outlined : Icons.check_circle_outline, color: isActive ? Colors.red : Colors.green, size: 18), 
                label: Text(isActive ? 'Deactivate' : 'Reactivate', style: TextStyle(color: isActive ? Colors.red : Colors.green))
              ),
              TextButton.icon(
                onPressed: () => _showUserDetails(context, userData), 
                icon: Icon(Icons.info_outline, color: primaryColor, size: 18), 
                label: Text('Details', style: TextStyle(color: primaryColor))
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            'Registered Users',
            style: TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white : const Color(0xFF1A1A1A)
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(width: 40, height: 4, decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2))),
        ),
        const SizedBox(height: 24),
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[400]),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Search users by name or phone...',
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(isListening ? Icons.mic : Icons.mic_none, color: primaryColor),
                        onPressed: _listen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_searchQuery.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: SearchSuggestionService.getFilteredSuggestions(_searchQuery, ['New Users', 'Active', 'Blocked', 'Recently Joined'])
                  .map((suggestion) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.search, size: 20, color: Colors.grey),
                        title: Text(
                          suggestion,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(Icons.north_west, size: 16, color: Colors.grey),
                        onTap: () {
                          setState(() {
                            _searchController.text = suggestion;
                            _searchQuery = suggestion;
                          });
                        },
                      ))
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'user').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text('Error loading users'));
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

              var users = snapshot.data?.docs ?? [];
              
              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase();
                users = users.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final phone = (data['mobile'] ?? '').toString().toLowerCase();
                  return name.contains(query) || phone.contains(query);
                }).toList();
              }

              if (users.isEmpty) {
                return Center(
                  child: Text(
                    _searchQuery.isEmpty ? 'No users registered yet' : 'No matching users found',
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])
                  )
                );
              }

              return RefreshIndicator(
                onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
                color: primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userData = users[index].data() as Map<String, dynamic>;
                    return _buildUserCard(context, userData);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
