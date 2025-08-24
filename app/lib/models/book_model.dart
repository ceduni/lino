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

  // Factory method to create Book from book info API response (without _id and dateAdded)
  factory Book.fromBookInfo(Map<String, dynamic> json) {
    // Handle authors - can be null, List, or single string
    List<String> authors = [];
    if (json['authors'] != null) {
      if (json['authors'] is List) {
        authors = (json['authors'] as List).cast<String>();
      } else if (json['authors'] is String) {
        authors = [json['authors'] as String];
      }
    }

    // Handle categories - can be null, List, or single string
    List<String> categories = [];
    if (json['categories'] != null) {
      if (json['categories'] is List) {
        categories = (json['categories'] as List).cast<String>();
      } else if (json['categories'] is String) {
        categories = [json['categories'] as String];
      }
    }

    return Book(
      id: json['_id'] ?? '', // Use empty string if no ID (for book info from API)
      isbn: json['isbn'],
      title: json['title'] ?? 'Unknown Title',
      authors: authors,
      description: json['description'],
      coverImage: json['coverImage'],
      publisher: json['publisher'],
      categories: categories,
      parutionYear: json['parutionYear'],
      pages: json['pages'],
      dateAdded: json['dateAdded'] != null 
          ? DateTime.parse(json['dateAdded']) 
          : DateTime.now(), // Use current time if no dateAdded
    );
  }
}

class ModifiableBook {
  String? isbn;
  String title;
  List<String> authors; 
  String? description;
  String? coverImage;
  String? publisher;
  List<String> categories;
  int? parutionYear;
  int? pages; 

  ModifiableBook({
    this.isbn,
    required this.title,
    required this.authors,
    this.description,
    this.coverImage,
    this.publisher,
    required this.categories,
    this.parutionYear,
    this.pages,
  });
}

class EditableBook {
  String isbn;
  String title;
  List<String> authors;
  String description;
  String coverImage;
  String publisher;
  int? parutionYear;
  int? pages;
  List<String> categories;

  EditableBook({
    required this.isbn,
    this.title = 'Unknown Title',
    this.authors = const ['Unknown Author'],
    this.description = 'No description available',
    this.coverImage = 'No thumbnail available',
    this.publisher = 'Unknown publisher',
    this.parutionYear,
    this.pages,
    this.categories = const ['Uncategorized'],
  });

  factory EditableBook.fromJson(Map<String, dynamic> json) {
    return EditableBook(
      isbn: json['isbn'],
      title: json['title'],
      authors: (json['authors'] as List).cast<String>(),
      description: json['description'],
      coverImage: json['coverImage'],
      publisher: json['publisher'],
      parutionYear: json['parutionYear'],
      pages: json['pages'],
      categories: (json['categories'] as List).cast<String>(),
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

  factory ExtendedBook.fromBook(Book book, String bookboxId, String bookboxName) {
    return ExtendedBook(
      id: book.id,
      isbn: book.isbn,
      title: book.title,
      authors: List<String>.from(book.authors),
      description: book.description,
      coverImage: book.coverImage,
      publisher: book.publisher,
      categories: List<String>.from(book.categories),
      parutionYear: book.parutionYear,
      pages: book.pages,
      dateAdded: book.dateAdded,
      bookboxId: bookboxId,
      bookboxName: bookboxName,
    );
  }
}

class BookStats {
  final int totalAdded;
  final int totalTook;

  BookStats({
    required this.totalAdded,
    required this.totalTook,
  });

  factory BookStats.fromJson(Map<String, dynamic> json) {
    return BookStats(
      totalAdded: json['totalAdded'],
      totalTook: json['totalTook'],
    );
  }
}