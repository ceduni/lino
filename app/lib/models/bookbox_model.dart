import 'book_model.dart';

class BookBox {
  final String id;
  final String name;
  final String? image; // Optional image URL
  final double longitude;
  final double latitude;
  final String? infoText;
  final String boroughId;
  final List<Book> books;
  final String owner;
  final bool isActive;

  BookBox({
    required this.id,
    required this.name,
    this.image,
    required this.longitude,
    required this.latitude,
    required this.boroughId,
    this.infoText,
    required this.books,
    required this.owner,
    required this.isActive,
  });

  factory BookBox.fromJson(Map<String, dynamic> json) {
    var booksList = json['books'] as List;
    List<Book> books = booksList.map((bookJson) => Book.fromJson(bookJson)).toList();

    return BookBox( 
      id: json['_id'],
      name: json['name'],
      image: json['image'],
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      boroughId: json['boroughId'],
      infoText: json['infoText'],
      books: books,
      owner: json['owner'],
      isActive: json['isActive'],
    );
  }
}

class BookBoxWithDistance extends BookBox {
  final double? distance; // Distance from the user's location

  BookBoxWithDistance({
    required super.id,
    required super.name,
    super.image,
    required super.longitude,
    required super.latitude,
    required super.boroughId,
    super.infoText,
    required super.books,
    this.distance,
    required super.owner,
    required super.isActive,
  });
}

class ShortenedBookBox {
  final String id;
  final String name;
  final String? infoText; // Optional info text
  final String? image; // Optional image URL
  final double longitude;
  final double latitude;
  final String boroughId;
  final int booksCount;
  final String owner;
  final bool isActive;
  final double? distance; // Optional distance from the user's location 

  ShortenedBookBox({
    required this.id,
    required this.name,
    this.infoText,
    this.image,
    required this.longitude,
    required this.latitude,
    required this.boroughId,
    required this.booksCount,
    required this.owner,
    required this.isActive,
    this.distance,
  });

  factory ShortenedBookBox.fromJson(Map<String, dynamic> json) {
    return ShortenedBookBox(
      id: json['_id'],
      name: json['name'],
      infoText: json['infoText'],
      image: json['image'],
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      booksCount: json['booksCount'],
      owner: json['owner'],
      isActive: json['isActive'],
      boroughId: json['boroughId'],
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null, // Handle optional distance
    );
  }
}

