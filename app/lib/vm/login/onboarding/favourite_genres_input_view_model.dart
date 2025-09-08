// app/lib/vm/favourite_genres_input_view_model.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouriteGenresInputViewModel extends ChangeNotifier {
  final TextEditingController genreController = TextEditingController();
  final List<String> _selectedGenres = [];
  List<String> _availableGenres = [];
  List<String> _filteredGenres = [];
  bool _isLoading = true;
  bool _showSearchInput = false;
  bool _showSuggestions = false;

  final List<String> _popularGenres = [
    'Romance', 'Mystery', 'Science', 'History', 'Biography', 'Adventure',
    'Fantasy', 'Drama', 'Comedy', 'Horror', 'Thriller', 'Self-help'
  ];

  // Getters
  List<String> get selectedGenres => _selectedGenres;
  List<String> get availableGenres => _availableGenres;
  List<String> get filteredGenres => _filteredGenres;
  List<String> get popularGenres => _popularGenres;
  bool get isLoading => _isLoading;
  bool get showSearchInput => _showSearchInput;
  bool get showSuggestions => _showSuggestions;

  void initialize() {
    _loadBookGenres();
    genreController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = genreController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredGenres = [];
      _showSuggestions = false;
    } else {
      _filteredGenres = _availableGenres
          .where((genre) => genre.toLowerCase().contains(query))
          .where((genre) => !_selectedGenres.contains(genre))
          .toList();
      _showSuggestions = _filteredGenres.isNotEmpty;
    }
    notifyListeners();
  }

  Future<void> _loadBookGenres() async {
    try {
      final String response = await rootBundle.loadString('lib/utils/constants/book_genres.json');
      final Map<String, dynamic> data = json.decode(response);
      _availableGenres = List<String>.from(data['genres']);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading book genres: $e');
      showToast('Error loading available genres');
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleGenre(String genre) {
    if (_selectedGenres.contains(genre)) {
      _selectedGenres.remove(genre);
    } else {
      _selectedGenres.add(genre);
    }
    notifyListeners();
  }

  void addGenre(String genre) {
    if (genre.isNotEmpty && !_selectedGenres.contains(genre)) {
      _selectedGenres.add(genre);
      genreController.clear();
      _showSuggestions = false;
      _filteredGenres = [];
      notifyListeners();
    }
  }

  void addCustomGenre() {
    final genre = genreController.text.trim();
    addGenre(genre);
  }

  void removeGenre(String genre) {
    _selectedGenres.remove(genre);
    notifyListeners();
  }

  void toggleSearchInput() {
    _showSearchInput = !_showSearchInput;
    if (!_showSearchInput) {
      genreController.clear();
      _showSuggestions = false;
      _filteredGenres = [];
    }
    notifyListeners();
  }

  Future<bool> continueToNext() async {
    if (_selectedGenres.isEmpty) return false;

    try {
      var userService = UserService();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      await userService.updateUser(token, favouriteGenres: _selectedGenres);
      showToast('Favourite genres saved successfully!');
      return true;
    } catch (e) {
      showToast('Error saving favourite genres: $e');
      return false;
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    genreController.removeListener(_onSearchChanged);
    genreController.dispose();
    super.dispose();
  }
}