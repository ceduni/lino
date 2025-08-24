// app/lib/vm/search_view_model.dart
import 'package:Lino_app/views/books/book_details_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/models/search_model.dart';
import 'package:Lino_app/services/bookbox_services.dart';
import 'package:Lino_app/services/search_services.dart';
import 'package:Lino_app/controllers/global_state_controller.dart';

import '../../views/bookboxes/book_box_page.dart';

class SearchViewModel extends ChangeNotifier {
  final GlobalStateController _globalState = Get.put(GlobalStateController());

  List<ShortenedBookBox> _bookBoxes = [];
  bool _isLoading = true;
  String? _error;
  bool _isGridMode = false;

  // Track expanded bookboxes and their loaded books
  Map<String, bool> _expandedBookBoxes = {};
  Map<String, List<Book>> _loadedBooks = {};
  Map<String, bool> _loadingBooks = {};

  List<ShortenedBookBox> get bookBoxes => _bookBoxes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isGridMode => _isGridMode;
  Map<String, bool> get expandedBookBoxes => _expandedBookBoxes;
  Map<String, List<Book>> get loadedBooks => _loadedBooks;
  Map<String, bool> get loadingBooks => _loadingBooks;
  GlobalStateController get globalState => _globalState;

  Future<void> initialize() async {
    await loadBookBoxes();

    _globalState.currentSelectedBookBox.listen((_) {
      notifyListeners();
    });
  }

  Future<void> loadBookBoxes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      SearchModel<ShortenedBookBox> data = await SearchService().searchBookboxes();
      _bookBoxes = data.results;
      _isLoading = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _bookBoxes = [];
    }
    notifyListeners();
  }

  void toggleViewMode() {
    _isGridMode = !_isGridMode;
    notifyListeners();
  }

  Future<void> toggleBookBoxExpansion(String bookBoxId) async {
    _expandedBookBoxes[bookBoxId] = !(_expandedBookBoxes[bookBoxId] ?? false);
    notifyListeners();

    // If expanding and books not loaded yet, load them
    if (_expandedBookBoxes[bookBoxId] == true && !_loadedBooks.containsKey(bookBoxId)) {
      await loadBooksForBookBox(bookBoxId);
    }
  }

  Future<Map<String, dynamic>> loadBooksForBookBox(String bookBoxId) async {
    _loadingBooks[bookBoxId] = true;
    notifyListeners();

    try {
      final bookBox = await BookboxService().getBookBox(bookBoxId);
      _loadedBooks[bookBoxId] = bookBox.books;
      _loadingBooks[bookBoxId] = false;
      notifyListeners();
      return {'success': true};
    } catch (e) {
      _loadingBooks[bookBoxId] = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  void navigateToBookBoxScreen(String bookBoxId) {
    Get.to(
          () => const BookBoxPage(),
      arguments: {
        'bookboxId': bookBoxId,
        'canInteract': false,
      },
    );
  }

  void navigateToBookDetailsScreen(ExtendedBook book) {
    Get.to(() => BookDetailsPage(book: book, fromBookbox: false),
      arguments: {
        'book': book,
      },
    );
  }

  List<Book>? getBooksForBookBox(String bookBoxId) {
    return _loadedBooks[bookBoxId];
  }

  bool isBookBoxLoading(String bookBoxId) {
    return _loadingBooks[bookBoxId] ?? false;
  }

  bool isBookBoxExpanded(String bookBoxId) {
    return _expandedBookBoxes[bookBoxId] ?? false;
  }
}