class Book {
  final String id;
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
    required this.id,
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
      id: json['_id'],
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

class ExtendedBook extends Book {
  final String bookboxId;
  final String bookboxName;

  ExtendedBook({
    required super.id,
    super.isbn,
    required super.title,
    required super.authors,
    super.description,
    super.coverImage,
    super.publisher,
    required super.categories,
    super.parutionYear,
    super.pages,
    required super.dateAdded,
    required this.bookboxId,
    required this.bookboxName,
  });

  factory ExtendedBook.fromJson(Map<String, dynamic> json) {
    return ExtendedBook(
      id: json['_id'],
      isbn: json['isbn'],
      title: json['title'],
      authors: (json['authors'] as List).cast<String>(),
      description: json['description'],
      coverImage: json['coverImage'],
      publisher: json['publisher'],
      categories: (json['categories'] as List).cast<String>(),
      parutionYear: json['parutionYear'],
      pages: json['pages'],
      dateAdded: DateTime.parse(json['dateAdded']),
      bookboxId: json['bookboxId'],
      bookboxName: json['bookboxName'],
    );
  }
}