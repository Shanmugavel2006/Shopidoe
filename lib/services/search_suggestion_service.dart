class SearchSuggestionService {
  static const List<String> userSuggestions = [
    'Stationery',
    'Cosmetics',
    'Notebooks',
    'Gel Pens',
    'Makeup Kit',
    'Lipsticks',
    'Face Wash',
    'School Bags',
    'Pencil Box',
    'Markers',
  ];

  static const List<String> adminInventorySuggestions = [
    'Out of Stock',
    'Stationery',
    'Cosmetics',
    'High Price',
    'Low Price',
  ];

  static const List<String> adminOrderSuggestions = [
    'Pending',
    'Delivered',
    'Cancelled',
    'Today',
    'High Value',
  ];

  static List<String> getFilteredSuggestions(String query, List<String> source) {
    if (query.isEmpty) return source.take(5).toList();
    return source
        .where((s) => s.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }
}
