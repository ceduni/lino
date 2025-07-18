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

  BookBox({
    required this.id,
    required this.name,
    this.image,
    required this.longitude,
    required this.latitude,
    required this.boroughId,
    this.infoText,
    required this.books,
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
  });
}