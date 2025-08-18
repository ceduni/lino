// app/lib/vm/bookboxes/bookbox_list_view_model.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/services/search_services.dart';

enum BookboxSortOption {
  byName('by name'),
  byLocation('by location'),
  byNumberOfBooks('by number of books');

  const BookboxSortOption(this.value);
  final String value;
}

class BookboxListViewModel extends ChangeNotifier {
  final SearchService _searchService = SearchService();

  // State
  List<ShortenedBookBox> _bookboxes = [];
  Position? _userPosition;
  String? _highlightedBookboxId;
  BookboxSortOption _sortOption = BookboxSortOption.byLocation;
  bool _isAscending = true;
  bool _isLoading = false;
  String? _error;
  bool _locationPermissionGranted = false;

  // Getters
  List<ShortenedBookBox> get bookboxes => _bookboxes;
  Position? get userPosition => _userPosition;
  String? get highlightedBookboxId => _highlightedBookboxId;
  BookboxSortOption get sortOption => _sortOption;
  bool get isAscending => _isAscending;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get locationPermissionGranted => _locationPermissionGranted;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initialize() async {
    await _requestLocationPermission();
    await loadBookboxes();
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

  Future<void> loadBookboxes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      double? longitude = _userPosition?.longitude;
      double? latitude = _userPosition?.latitude;

      final response = await _searchService.searchBookboxes(
        cls: _sortOption.value,
        asc: _isAscending,
        longitude: _sortOption == BookboxSortOption.byLocation ? longitude : null,
        latitude: _sortOption == BookboxSortOption.byLocation ? latitude : null,
      );

      _bookboxes = response.results;
      _error = null;
    } catch (e) {
      _error = _parseError(e);
      print('Error loading bookboxes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  String _parseError(dynamic error) {
    if (error.toString().contains('400')) {
      return 'Invalid request. Please try again.';
    } else if (error.toString().contains('404')) {
      return 'No bookboxes found.';
    } else if (error.toString().contains('500')) {
      return 'Server error. Please try again later.';
    } else if (error.toString().contains('timeout') || error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please check your connection.';
    } else if (error.toString().contains('SocketException') || error.toString().contains('NetworkException')) {
      return 'Network error. Please check your internet connection.';
    }
    return 'An error occurred while loading bookboxes.';
  }

  Future<void> setSortOption(BookboxSortOption option, bool ascending) async {
    if (_sortOption != option || _isAscending != ascending) {
      _sortOption = option;
      _isAscending = ascending;
      await loadBookboxes();
    }
  }

  void highlightBookbox(String bookboxId) {
    _highlightedBookboxId = bookboxId;
    
    // Move highlighted bookbox to the top of the list
    final index = _bookboxes.indexWhere((bb) => bb.id == bookboxId);
    if (index != -1) {
      final highlightedBookbox = _bookboxes.removeAt(index);
      _bookboxes.insert(0, highlightedBookbox);
    }
    
    notifyListeners();
  }

  void clearHighlight() {
    _highlightedBookboxId = null;
    notifyListeners();
  }

  Future<void> refreshBookboxes() async {
    await _getCurrentLocation();
    await loadBookboxes();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> retryLoadBookboxes() async {
    await loadBookboxes();
  }

  // Helper method to get bookbox by ID
  ShortenedBookBox? getBookboxById(String id) {
    try {
      return _bookboxes.firstWhere((bb) => bb.id == id);
    } catch (e) {
      return null;
    }
  }

  // Helper method to check if a bookbox is highlighted
  bool isBookboxHighlighted(String id) {
    return _highlightedBookboxId == id;
  }

  List<BookboxSortOption> getSortOptions() {
    return BookboxSortOption.values;
  }
}
