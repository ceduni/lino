BookSuggestion mapToBookSuggestion(Map<String, dynamic> json) {
  final volumeInfo = json['volumeInfo'] as Map<String, dynamic>;
  final title = volumeInfo['title'] as String? ?? 'Unknown Title';
  
  String author = 'Unknown Author';
  if (volumeInfo['authors'] != null) {
    if (volumeInfo['authors'] is List) {
      final authors = volumeInfo['authors'] as List;
      author = authors.isNotEmpty ? authors.join(', ') : 'Unknown Author';
    } else {
      author = volumeInfo['authors'].toString();
    }
  }
  
  return BookSuggestion(title: title, author: author);
}

class BookSuggestion {
  final String title;
  final String author;

  BookSuggestion({required this.title, required this.author});

  factory BookSuggestion.fromJson(Map<String, dynamic> json) {
    return BookSuggestion(
      title: json['title'] as String,
      author: json['author'] as String
    );
  }

  @override
  String toString() {
    return 'BookSuggestion(title: $title, author: $author)';
  }
}