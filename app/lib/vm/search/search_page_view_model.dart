// app/lib/vm/search/search_page_view_model.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/models/search_model.dart';
import 'package:Lino_app/services/search_services.dart';
import 'package:Lino_app/utils/constants/search_types.dart';

enum SortOption {
  byName('by name'),
  byLocation('by location'),
  byNumberOfBooks('by number of books'),
  byTitle('by title'),
  byAuthor('by author'),
  byYear('by year'),
  byMostRecentActivity('by most recent activity');

  const SortOption(this.value);
  final String value;
}

class SearchPageViewModel extends ChangeNotifier {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();

  // Debouncing
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  // Current search state
  SearchType _currentSearchType = SearchType.bookboxes;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  bool _hasSearched = false; // Track if we've performed at least one search

  // User location
  Position? _userPosition;
  bool _locationPermissionGranted = false;

  // Bookboxes results
  List<ShortenedBookBox> _bookboxResults = [];
  Pagination? _bookboxPagination;
  SortOption _bookboxSortOption = SortOption.byName;
  bool _bookboxAscending = true;
  int _bookboxCurrentPage = 1;

  // Books results
  List<ExtendedBook> _bookResults = [];
  Pagination? _bookPagination;
  SortOption _bookSortOption = SortOption.byTitle;
  bool _bookAscending = true;
  int _bookCurrentPage = 1;

  // Getters
  TextEditingController get searchController => _searchController;
  SearchType get currentSearchType => _currentSearchType;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Bookboxes getters
  List<ShortenedBookBox> get bookboxResults => _bookboxResults;
  Pagination? get bookboxPagination => _bookboxPagination;
  SortOption get bookboxSortOption => _bookboxSortOption;
  bool get bookboxAscending => _bookboxAscending;
  int get bookboxCurrentPage => _bookboxCurrentPage;

  // Books getters
  List<ExtendedBook> get bookResults => _bookResults;
  Pagination? get bookPagination => _bookPagination;
  SortOption get bookSortOption => _bookSortOption;
  bool get bookAscending => _bookAscending;
  int get bookCurrentPage => _bookCurrentPage;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void initialize() {
    _searchController.addListener(_onSearchChanged);
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        _locationPermissionGranted = true;
        await _getCurrentLocation();
      } else {
        _locationPermissionGranted = false;
        print('Location permission denied');
      }
    } catch (e) {
      print('Error requesting location permission: $e');
      _locationPermissionGranted = false;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (_locationPermissionGranted) {
        _userPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
        print('User location: ${_userPosition?.latitude}, ${_userPosition?.longitude}');
      }
    } catch (e) {
      print('Error getting current location: $e');
      _userPosition = null;
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _searchQuery) {
      _searchQuery = query;
      
      // Cancel previous timer
      _debounceTimer?.cancel();
      
      if (query.isNotEmpty) {
        // Start new debounced search
        _debounceTimer = Timer(_debounceDuration, () {
          _performSearch();
        });
      } else {
        _clearResults();
        notifyListeners();
      }
    }
  }

  void switchSearchType(SearchType type) {
    if (_currentSearchType != type) {
      _currentSearchType = type;
      _clearResults();
      if (_searchQuery.isNotEmpty) {
        _performSearch();
      }
      notifyListeners();
    }
  }

  void _clearResults() {
    _bookboxResults.clear();
    _bookResults.clear();
    _bookboxPagination = null;
    _bookPagination = null;
    _bookboxCurrentPage = 1;
    _bookCurrentPage = 1;
    _error = null;
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      switch (_currentSearchType) {
        case SearchType.bookboxes:
          await _searchBookboxes();
          _hasSearched = true;
        case SearchType.books:
          await _searchBooks();
          _hasSearched = true;
      }
    } catch (e) {
      _handleSearchError(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  void _handleSearchError(dynamic error) {
    String errorMessage = 'An error occurred while searching';
    
    // Parse different types of errors
    if (error.toString().contains('400')) {
      errorMessage = 'Invalid search query. Please try different keywords.';
    } else if (error.toString().contains('404')) {
      errorMessage = 'No results found for your search.';
    } else if (error.toString().contains('500')) {
      errorMessage = 'Server error. Please try again later.';
    } else if (error.toString().contains('timeout') || error.toString().contains('TimeoutException')) {
      errorMessage = 'Search timed out. Please check your connection and try again.';
    } else if (error.toString().contains('SocketException') || error.toString().contains('NetworkException')) {
      errorMessage = 'Network error. Please check your internet connection.';
    }
    
    _error = errorMessage;
    print('Search error: $error');
  }

  // Method to retry search (useful for error recovery)
  void retrySearch() {
    if (_searchQuery.isNotEmpty) {
      _performSearch();
    }
  }

  // Method to clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _searchBookboxes() async {
    final response = await _searchService.searchBookboxes(
      q: _searchQuery,
      cls: _bookboxSortOption.value,
      asc: _bookboxAscending,
      limit: 10,
      page: _bookboxCurrentPage,
      // Include user location if available for distance calculation
      longitude: _userPosition?.longitude,
      latitude: _userPosition?.latitude,
    );

    _bookboxResults = response.results;
    _bookboxPagination = response.pagination;
  }

  Future<void> _searchBooks() async {
    final response = await _searchService.searchBooks(
      q: _searchQuery,
      cls: _bookSortOption.value,
      asc: _bookAscending,
      limit: 10,
      page: _bookCurrentPage,
    );

    _bookResults = response.results;
    _bookPagination = response.pagination;
  }

  // Bookbox sorting and pagination
  void setBookboxSort(SortOption option, bool ascending) {
    _bookboxSortOption = option;
    _bookboxAscending = ascending;
    _bookboxCurrentPage = 1;
    if (_searchQuery.isNotEmpty) {
      _performSearch();
    }
  }

  void goToBookboxPage(int page) {
    if (page >= 1 && page <= (_bookboxPagination?.totalPages ?? 1)) {
      _bookboxCurrentPage = page;
      _performSearch();
    }
  }

  void nextBookboxPage() {
    if (_bookboxPagination?.hasNextPage == true) {
      _bookboxCurrentPage++;
      _performSearch();
    }
  }

  void previousBookboxPage() {
    if (_bookboxPagination?.hasPrevPage == true) {
      _bookboxCurrentPage--;
      _performSearch();
    }
  }

  // Book sorting and pagination
  void setBookSort(SortOption option, bool ascending) {
    _bookSortOption = option;
    _bookAscending = ascending;
    _bookCurrentPage = 1;
    if (_searchQuery.isNotEmpty) {
      _performSearch();
    }
  }

  void goToBookPage(int page) {
    if (page >= 1 && page <= (_bookPagination?.totalPages ?? 1)) {
      _bookCurrentPage = page;
      _performSearch();
    }
  }

  void nextBookPage() {
    if (_bookPagination?.hasNextPage == true) {
      _bookCurrentPage++;
      _performSearch();
    }
  }

  void previousBookPage() {
    if (_bookPagination?.hasPrevPage == true) {
      _bookCurrentPage--;
      _performSearch();
    }
  }

  // Placeholder methods for navigation
  void onBookboxTap(ShortenedBookBox bookbox) {
    // TODO: Navigate to bookbox details page
    print('Tapped on bookbox: ${bookbox.name}');
  }

  void onBookTap(ExtendedBook book) {
    // TODO: Navigate to book details page
    print('Tapped on book: ${book.title}');
  }

  List<SortOption> getBookboxSortOptions() {
    return [
      SortOption.byName,
      SortOption.byLocation,
      SortOption.byNumberOfBooks,
    ];
  }

  List<SortOption> getBookSortOptions() {
    return [
      SortOption.byTitle,
      SortOption.byAuthor,
      SortOption.byYear,
      SortOption.byMostRecentActivity,
    ];
  }
}
