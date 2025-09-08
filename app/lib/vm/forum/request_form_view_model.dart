// app/lib/vm/forum/request_form_view_model.dart
import 'dart:async';
import 'package:Lino_app/models/book_suggestion.dart';
import 'package:Lino_app/models/request_model.dart';
import 'package:Lino_app/models/search_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/services/book_request_services.dart';
import 'package:Lino_app/services/search_services.dart';

class RequestFormViewModel extends ChangeNotifier {
  final BookRequestService _bookRequestService = BookRequestService();
  final SearchService _searchService = SearchService();

  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  // State
  bool _isLoading = false;
  bool _showSuggestions = false;
  bool _isLoadingSuggestions = false;
  List<BookSuggestion> _suggestions = [];
  BookSuggestion? _selectedSuggestion;
  bool _isCustomTitle = false;
  bool _isSearchLocked = false;
  bool _isLoadingSimilarRequests = false;
  int? _similarRequestsCount;
  String? _error;
  Timer? _debounceTimer;

  // Getters
  bool get isLoading => _isLoading;
  bool get showSuggestions => _showSuggestions;
  bool get isLoadingSuggestions => _isLoadingSuggestions;
  List<BookSuggestion> get suggestions => _suggestions;
  BookSuggestion? get selectedSuggestion => _selectedSuggestion;
  bool get isCustomTitle => _isCustomTitle;
  bool get isSearchLocked => _isSearchLocked;
  bool get isLoadingSimilarRequests => _isLoadingSimilarRequests;
  int? get similarRequestsCount => _similarRequestsCount;
  String? get error => _error;

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void initialize() {
    titleController.addListener(_onTitleChanged);
    focusNode.addListener(_onFocusChanged);
  }

  void _onTitleChanged() {
    final query = titleController.text.trim();
    
    if (query.isEmpty) {
      _showSuggestions = false;
      _suggestions.clear();
      _selectedSuggestion = null;
      _isCustomTitle = false;
      _isSearchLocked = false;
      notifyListeners();
      return;
    }

    // Don't search if search is locked (user selected a suggestion or custom title)
    if (_isSearchLocked) {
      return;
    }

    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Start new timer for debounced search
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchBookSuggestions(query);
    });
  }

  void _onFocusChanged() {
    if (!focusNode.hasFocus) {
      // Hide suggestions when focus is lost
      _showSuggestions = false;
      notifyListeners();
    }
  }

  Future<void> _searchBookSuggestions(String query) async {
    if (query.length < 2) return;

    _isLoadingSuggestions = true;
    _showSuggestions = true;
    _error = null;
    notifyListeners();

    try {
      final suggestions = await _bookRequestService.getBookSuggestions(query, limit: 10);
      _suggestions = suggestions;
      _isLoadingSuggestions = false;
      _error = null;
    } catch (e) {
      _suggestions.clear();
      _isLoadingSuggestions = false;
      _error = 'Failed to search for books: ${e.toString()}';
      print('Error searching suggestions: $e');
    }

    notifyListeners();
  }

  void selectSuggestion(BookSuggestion suggestion) {
    _selectedSuggestion = suggestion;
    _isSearchLocked = true; // Lock search to prevent re-triggering
    titleController.text = suggestion.title;
    _showSuggestions = false;
    _isCustomTitle = false;
    focusNode.unfocus();
    _searchSimilarRequests(suggestion.title);
    notifyListeners();
  }

  void useCustomTitle() {
    _selectedSuggestion = null;
    _isSearchLocked = true; // Lock search for custom title
    _showSuggestions = false;
    _isCustomTitle = true;
    focusNode.unfocus();
    _searchSimilarRequests(titleController.text.trim());
    notifyListeners();
  }

  void onTitleFieldTap() {
    if (!_isSearchLocked && _suggestions.isNotEmpty && titleController.text.isNotEmpty) {
      _showSuggestions = true;
      notifyListeners();
    }
  }

  void unlockSearch() {
    _isSearchLocked = false;
    _selectedSuggestion = null;
    _isCustomTitle = false;
    _similarRequestsCount = null;
    
    // Trigger search with current text if not empty
    final query = titleController.text.trim();
    if (query.isNotEmpty) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _searchBookSuggestions(query);
      });
    }
    
    notifyListeners();
  }

  void clearSearch() {
    _isSearchLocked = false;
    _selectedSuggestion = null;
    _isCustomTitle = false;
    _showSuggestions = false;
    _suggestions.clear();
    _similarRequestsCount = null;
    titleController.clear();
    notifyListeners();
  }

  Future<void> _searchSimilarRequests(String bookTitle) async {
    if (bookTitle.trim().isEmpty) return;

    _isLoadingSimilarRequests = true;
    notifyListeners();

    try {
      final searchResult = await _searchService.searchRequests(
        q: bookTitle,
        filter: RequestFilter.all,
        sortBy: RequestSortBy.date,
        sortOrder: SortOrder.desc,
        limit: 1, // We only need the count, not the actual results
      );
      
      _similarRequestsCount = searchResult.pagination.totalResults;
      _isLoadingSimilarRequests = false;
    } catch (e) {
      _similarRequestsCount = null;
      _isLoadingSimilarRequests = false;
      print('Error searching similar requests: $e');
    }

    notifyListeners();
  }

  Future<bool> submitForm() async {
    if (titleController.text.trim().isEmpty) {
      _error = 'Please enter the title of the book';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        _error = 'You need to be logged in to create a request';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _bookRequestService.requestBookToUsers(
        token,
        titleController.text.trim(),
        cm: messageController.text.trim(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to send request: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void resetForm() {
    titleController.clear();
    messageController.clear();
    _selectedSuggestion = null;
    _isCustomTitle = false;
    _isSearchLocked = false;
    _showSuggestions = false;
    _suggestions.clear();
    _similarRequestsCount = null;
    _error = null;
    notifyListeners();
  }
}
