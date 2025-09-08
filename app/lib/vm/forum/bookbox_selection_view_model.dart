import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/models/book_suggestion.dart';
import 'package:Lino_app/models/search_model.dart';
import 'package:Lino_app/services/search_services.dart';
import 'package:Lino_app/services/book_request_services.dart';

class BookboxSelectionViewModel extends ChangeNotifier {
  final SearchService _searchService = SearchService();
  final BookRequestService _bookRequestService = BookRequestService();

  // Montreal center coordinates
  static const LatLng _montrealCenter = LatLng(45.5017, -73.5673);

  // State
  bool _isLoading = false;
  bool _isSubmitting = false;
  List<ShortenedBookBox> _bookboxes = [];
  List<String> _selectedBookboxIds = [];
  String? _error;
  Position? _userPosition;
  bool _locationPermissionGranted = false;

  // Request data
  String _title = '';
  String _customMessage = '';
  BookSuggestion? _selectedSuggestion;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  List<ShortenedBookBox> get bookboxes => _bookboxes;
  List<String> get selectedBookboxIds => _selectedBookboxIds;
  String? get error => _error;
  Position? get userPosition => _userPosition;
  bool get locationPermissionGranted => _locationPermissionGranted;
  String get title => _title;
  String get customMessage => _customMessage;
  BookSuggestion? get selectedSuggestion => _selectedSuggestion;

  LatLng get initialLocation {
    if (_locationPermissionGranted && _userPosition != null) {
      return LatLng(_userPosition!.latitude, _userPosition!.longitude);
    }
    return _montrealCenter;
  }

  void initialize(Map<String, dynamic> arguments) {
    _title = arguments['title'] ?? '';
    _customMessage = arguments['customMessage'] ?? '';
    _selectedSuggestion = arguments['selectedSuggestion'];
    if (arguments['preselectedBookboxId'] != null) {
      _selectedBookboxIds = [arguments['preselectedBookboxId']];
    }
    
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _loadBookboxes();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _loadBookboxes();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _loadBookboxes();
      return;
    }

    _locationPermissionGranted = true;
    await _getCurrentLocation();
    _loadBookboxes();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _userPosition = position;
      notifyListeners();
    } catch (e) {
      print('Error getting location: $e');
      // Continue with Montreal center if location fails
    }
  }

  Future<void> _loadBookboxes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      double longitude = _montrealCenter.longitude;
      double latitude = _montrealCenter.latitude;

      // Use user location if available
      if (_locationPermissionGranted && _userPosition != null) {
        longitude = _userPosition!.longitude;
        latitude = _userPosition!.latitude;
      }

      final SearchModel<ShortenedBookBox> result = await _searchService.findNearestBookboxes(
        longitude,
        latitude,
        maxDistance: 100.0, // 100km radius
        limit: 100,
      );

      _bookboxes = result.results;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load bookboxes: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void onSelectionChanged(List<String> selectedIds) {
    _selectedBookboxIds = selectedIds;
    notifyListeners();
  }

  Future<bool> createRequest() async {
    if (_selectedBookboxIds.isEmpty) {
      _error = 'Please select at least one bookbox';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        _error = 'You need to be logged in to create a request';
        _isSubmitting = false;
        notifyListeners();
        return false;
      }

      await _bookRequestService.requestBookToUsers(
        token,
        _title,
        cm: _customMessage.isNotEmpty ? _customMessage : null,
        bookboxIds: _selectedBookboxIds,
      );

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create request: ${e.toString()}';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void retry() {
    _loadBookboxes();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
