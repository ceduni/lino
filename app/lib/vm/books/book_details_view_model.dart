import 'package:flutter/material.dart';
import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/services/book_services.dart';

class BookDetailsViewModel extends ChangeNotifier {
  final BookService _bookService = BookService();
  
  Book? _book;
  BookStats? _bookStats;
  bool _isLoadingStats = false;
  String? _statsError;
  bool _isDescriptionExpanded = false;

  Book? get book => _book;
  BookStats? get bookStats => _bookStats;
  bool get isLoadingStats => _isLoadingStats;
  String? get statsError => _statsError;
  bool get isDescriptionExpanded => _isDescriptionExpanded;

  void setBook(Book book) {
    _book = book;
    notifyListeners();
    
    // Load book stats if ISBN is available
    if (book.isbn != null && book.isbn!.isNotEmpty) {
      loadBookStats(book.isbn!);
    }
  }

  Future<void> loadBookStats(String isbn) async {
    _isLoadingStats = true;
    _statsError = null;
    notifyListeners();

    try {
      _bookStats = await _bookService.getBookStats(isbn);
      _statsError = null;
    } catch (e) {
      _statsError = e.toString();
      _bookStats = null;
    }

    _isLoadingStats = false;
    notifyListeners();
  }

  void toggleDescriptionExpanded() {
    _isDescriptionExpanded = !_isDescriptionExpanded;
    notifyListeners();
  }

  void reset() {
    _book = null;
    _bookStats = null;
    _isLoadingStats = false;
    _statsError = null;
    _isDescriptionExpanded = false;
    notifyListeners();
  }
}
