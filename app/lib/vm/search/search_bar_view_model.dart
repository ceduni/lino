// app/lib/vm/search_bar_view_model.dart
import 'package:flutter/material.dart';
import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/models/search_model.dart';
import 'package:Lino_app/services/search_services.dart';
import 'package:Lino_app/utils/constants/search_types.dart';

class SearchBarViewModel extends ChangeNotifier {
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  List<String> _results = [];
  bool _isLoading = false;
  String? _error;
  SearchType _searchType = SearchType.books;

  FocusNode get focusNode => _focusNode;
  String get query => _query;
  List<String> get results => _results;
  bool get isLoading => _isLoading;
  String? get error => _error;
  SearchType get searchType => _searchType;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void setSearchType(SearchType type) {
    _searchType = type;
    _clearResults();
    notifyListeners();
  }

  void showSearchResults(String query) {
    _query = query;
    notifyListeners();
  }

  void hideSearchResults() {
    _query = '';
    _results.clear();
    _focusNode.unfocus();
    notifyListeners();
  }

  void _clearResults() {
    _results.clear();
    _query = '';
    _error = null;
  }

  Future<void> search(String query) async {
    _query = query;
    _error = null;

    if (query.isEmpty) {
      _results.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      switch (_searchType) {
        case SearchType.books:
          await _searchBooks(query);
          break;
        case SearchType.bookboxes:
          await _searchBookBoxes(query);
          break;
      }
    } catch (e) {
      _error = e.toString();
      _results.clear();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _searchBooks(String query) async {
    SearchModel<ExtendedBook> response = await SearchService().searchBooks(q: query);
    _results = response.results.map((book) => book.title).toList();
  }

  Future<void> _searchBookBoxes(String query) async {
    // Assuming you have a searchBookBoxes method in SearchService
    // If not, you'll need to implement it
    try {
      final response = await SearchService().searchBookboxes(q: query);
      _results = response.results.map((bookbox) => bookbox.name).toList();
    } catch (e) {
      // Fallback if searchBookboxes doesn't exist
      _results = [];
    }
  }

  void onSubmitted(String value) {
    if (value.isNotEmpty) {
      showSearchResults(value);
    }
  }

  void unfocus() {
    _focusNode.unfocus();
  }
}