// app/lib/vm/favourite_genres_view_model.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/services/user_services.dart';

class FavouriteGenresViewModel extends ChangeNotifier {
  final TextEditingController genreController = TextEditingController();
  final List<String> _selectedGenres = [];
  List<String> _availableGenres = [];
  List<String> _filteredGenres = [];
  bool _isLoading = true;
  bool _showSuggestions = false;
  String? _token;

  List<String> get selectedGenres => _selectedGenres;
  List<String> get filteredGenres => _filteredGenres;
  bool get isLoading => _isLoading;
  bool get showSuggestions => _showSuggestions;

  void initialize() {
    _loadBookGenres();
    _loadUserGenres();
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
    } catch (e) {
      print('Error loading book genres: $e');
      showToast('Error loading available genres');
    }
  }

  Future<void> _loadUserGenres() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      if (_token == null) throw Exception('No token found');

      final userService = UserService();
      final user = await userService.getUser(_token!);
      final favouriteGenres = user.favouriteGenres;

      for (var item in favouriteGenres) {
        _selectedGenres.add(item);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading user genres: $e');
      _isLoading = false;
      notifyListeners();
    }
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

  Future<bool> finish() async {
    try {
      var userService = UserService();
      await userService.updateUser(_token!, favouriteGenres: _selectedGenres);
      showToast('Favourite genres updated successfully!');
      return true;
    } catch (e) {
      showToast('Error updating favourite genres: $e');
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