import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../services/speech_service.dart';

class AdminHistoryView extends StatefulWidget {
  const AdminHistoryView({super.key});

  @override
  State<AdminHistoryView> createState() => _AdminHistoryViewState();
}

class _AdminHistoryViewState extends State<AdminHistoryView> with SpeechRecognitionMixin<AdminHistoryView> {
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

  // Mocked data converted to a mutable list
  List<Map<String, dynamic>> _historyItems = [
    {'id': '1', 'message': 'New order received from saranraja', 'time': '29/4/2026 18:20', 'selected': false},
    {'id': '2', 'message': 'New user "Varshini" registered', 'time': '28/4/2026 20:15', 'selected': false},
    {'id': '3', 'message': 'New order received from saranraja', 'time': '28/4/2026 19:29', 'selected': false},
    {'id': '4', 'message': 'New order received from saranraja', 'time': '28/4/2026 19:11', 'selected': false},
    {'id': '5', 'message': 'New user "saranraja" registered', 'time': '28/4/2026 15:21', 'selected': false},
    {'id': '6', 'message': 'New order received from saran', 'time': '27/4/2026 21:48', 'selected': false},
    {'id': '7', 'message': 'New order received from saran', 'time': '27/4/2026 15:32', 'selected': false},
    {'id': '8', 'message': 'New order received from saran', 'time': '27/4/2026 15:21', 'selected': false},
  ];

  bool _isSelectionMode = false;

  void _toggleSelectAll(bool? value) {
    setState(() {
      for (var item in _historyItems) {
        item['selected'] = value ?? false;
      }
    });
  }

  void _deleteSelected() {
    setState(() {
      _historyItems.removeWhere((item) => item['selected'] == true);
      _isSelectionMode = false;
    });
  }

  void _deleteItem(String id) {
    setState(() {
      _historyItems.removeWhere((item) => item['id'] == id);
    });
  }

  Widget _buildHistoryItem(BuildContext context, Map<String, dynamic> item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isSelectionMode)
            Checkbox(
              value: item['selected'] as bool,
              onChanged: (val) {
                setState(() {
                  item['selected'] = val;
                });
              },
              activeColor: primaryColor,
            )
          else
            Container(
              margin: const EdgeInsets.only(top: 14),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['message'],
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600, 
                      color: isDark ? Colors.white : const Color(0xFF2D2D2D)
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['time'],
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[400]),
            onPressed: () => _deleteItem(item['id']),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool allSelected = _historyItems.isNotEmpty && _historyItems.every((item) => item['selected'] == true);
    bool anySelected = _historyItems.any((item) => item['selected'] == true);

    final filteredItems = _historyItems.where((item) {
      final message = item['message'].toString().toLowerCase();
      final time = item['time'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return message.contains(query) || time.contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Complete History',
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A)
                ),
              ),
              if (_historyItems.isNotEmpty)
                IconButton(
                  icon: Icon(
                    _isSelectionMode ? Icons.close : Icons.checklist, 
                    color: primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = !_isSelectionMode;
                      if (!_isSelectionMode) {
                        for (var item in _historyItems) {
                          item['selected'] = false;
                        }
                      }
                    });
                  },
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
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
                      hintText: 'Search history...',
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
        if (_isSelectionMode && _historyItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Checkbox(
                  value: allSelected,
                  onChanged: _toggleSelectAll,
                  activeColor: primaryColor,
                ),
                Text('Select All', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                const Spacer(),
                if (anySelected)
                  ElevatedButton.icon(
                    onPressed: _deleteSelected,
                    icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                    label: const Text('Delete', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: filteredItems.isEmpty 
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty ? 'No history available' : 'No matching history found',
                    style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
                  color: primaryColor,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: filteredItems.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[100]),
                    itemBuilder: (context, index) {
                      return _buildHistoryItem(context, filteredItems[index]);
                    },
                  ),
                ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
