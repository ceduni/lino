import 'book_model.dart';

class BookBox {
  final String name;
  final List<double> location;
  final String? infoText;
  final List<Book> books;

  BookBox({
    required this.name,
    required this.location,
    this.infoText,
    required this.books,
  });

  factory BookBox.fromJson(Map<String, dynamic> json) {
    var locationList = json['location'] as List;
    List<double> location = locationList.cast<double>();

    var booksList = json['books'] as List;
    List<Book> books = booksList.map((bookJson) => Book.fromJson(bookJson)).toList();

    return BookBox(
      name: json['name'],
      location: location,
      infoText: json['infoText'],
      books: books,
    );
  }
}
