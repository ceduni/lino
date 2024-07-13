import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/utils/mock_data/mock_book_boxes.dart';
import 'package:Lino_app/utils/mock_data/mock_books.dart';

class MockData {
  static List<BookBox> getBookBoxes() {
    return mockBookBoxes;
  }

  static List<Book> getBooks() {
    return mockBooks;
  }
}
