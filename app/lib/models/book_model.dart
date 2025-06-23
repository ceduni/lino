class Book {
  final String? isbn;
  final String title;
  final List<String> authors;
  final String? description;
  final String? coverImage;
  final String? publisher;
  final List<String> categories;
  final int? parutionYear;
  final int? pages;
  final DateTime dateAdded;

  Book({
    this.isbn,
    required this.title,
    required this.authors,
    this.description,
    this.coverImage,
    this.publisher,
    required this.categories,
    this.parutionYear,
    this.pages,
    required this.dateAdded,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    var authorsList = json['authors'] as List;
    List<String> authors = authorsList.cast<String>();

    var categoriesList = json['categories'] as List;
    List<String> categories = categoriesList.cast<String>();

    return Book(
      isbn: json['isbn'],
      title: json['title'],
      authors: authors,
      description: json['description'],
      coverImage: json['coverImage'],
      publisher: json['publisher'],
      categories: categories,
      parutionYear: json['parutionYear'],
      pages: json['pages'],
      dateAdded: DateTime.parse(json['dateAdded']),
    );
  }
}
