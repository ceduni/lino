import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_radius_setup_page.dart';

class FavouriteGenresInputPage extends StatefulWidget {
  final String token;
  final SharedPreferences prefs;

  const FavouriteGenresInputPage({required this.token, required this.prefs, super.key});

  @override
  _FavouriteGenresInputPageState createState() => _FavouriteGenresInputPageState();
}

class _FavouriteGenresInputPageState extends State<FavouriteGenresInputPage> {
  final TextEditingController _genreController = TextEditingController();
  final List<String> _selectedGenres = [];
  List<String> _availableGenres = [];
  List<String> _filteredGenres = [];
  bool _isLoading = true;
  bool _showSearchInput = false;
  bool _showSuggestions = false;

  // Most popular genres selected from the book_genres.json
  final List<String> _popularGenres = [
    'Romance',
    'Mystery',
    'Science',
    'History',
    'Biography',
    'Adventure',
    'Fantasy',
    'Drama',
    'Comedy',
    'Horror',
    'Thriller',
    'Self-help'
  ];

  @override
  void initState() {
    super.initState();
    _loadBookGenres();
    _genreController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _genreController.removeListener(_onSearchChanged);
    _genreController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _genreController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredGenres = [];
        _showSuggestions = false;
      } else {
        _filteredGenres = _availableGenres
            .where((genre) => genre.toLowerCase().contains(query))
            .where((genre) => !_selectedGenres.contains(genre))
            .take(5)
            .toList();
        _showSuggestions = _filteredGenres.isNotEmpty;
      }
    });
  }

  Future<void> _loadBookGenres() async {
    try {
      final String response = await rootBundle.loadString('lib/utils/constants/book_genres.json');
      final Map<String, dynamic> data = json.decode(response);
      setState(() {
        _availableGenres = List<String>.from(data['genres']);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading book genres: $e');
      showToast('Error loading available genres');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  void _addGenre(String genre) {
    if (genre.isNotEmpty && !_selectedGenres.contains(genre)) {
      setState(() {
        _selectedGenres.add(genre);
        _genreController.clear();
        _showSuggestions = false;
        _filteredGenres = [];
      });
    }
  }

  void _addCustomGenre() {
    final genre = _genreController.text.trim();
    _addGenre(genre);
  }

  void _removeGenre(String genre) {
    setState(() {
      _selectedGenres.remove(genre);
    });
  }

  void _toggleSearchInput() {
    setState(() {
      _showSearchInput = !_showSearchInput;
      if (!_showSearchInput) {
        _genreController.clear();
        _showSuggestions = false;
        _filteredGenres = [];
      }
    });
  }

  Future<void> _continue() async {
    if (_selectedGenres.isEmpty) return;

    try {
      var userService = UserService();
      await userService.updateUser(widget.token, favouriteGenres: _selectedGenres);
      showToast('Favourite genres saved successfully!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationRadiusSetupPage(token: widget.token, prefs: widget.prefs),
        ),
      );
    } catch (e) {
      showToast('Error saving favourite genres: $e');
    }
  }
  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationRadiusSetupPage(token: widget.token, prefs: widget.prefs),
      ),
    );
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4277B8),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header section
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'What genres do you love?',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Select your favourite book genres to get personalized recommendations',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    // Content section
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Popular genres section
                            if (!_showSearchInput) ...[
                              Text(
                                'Popular Genres:',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 12),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: _popularGenres.map((genre) {
                                  final isSelected = _selectedGenres.contains(genre);
                                  return GestureDetector(
                                    onTap: () => _toggleGenre(genre),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white : Colors.transparent,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        genre,
                                        style: TextStyle(
                                          color: isSelected ? Color(0xFF4277B8) : Colors.white,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 20),
                              
                              // Others button
                              Center(
                                child: OutlinedButton(
                                  onPressed: _toggleSearchInput,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.white, width: 1.5),
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  ),
                                  child: Text(
                                    'Others',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                            
                            // Search input section
                            if (_showSearchInput) ...[
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _toggleSearchInput,
                                    icon: Icon(Icons.arrow_back, color: Colors.white),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _genreController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                        hintText: 'Search or enter custom genre',
                                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                                        filled: true,
                                        fillColor: Color(0xFFE0F7FA),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onSubmitted: (_) => _addCustomGenre(),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.add, color: Colors.white),
                                    onPressed: _addCustomGenre,
                                  ),
                                ],
                              ),
                              
                              // Autocomplete suggestions
                              if (_showSuggestions)
                                Container(
                                  margin: EdgeInsets.only(top: 8, left: 48),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: _filteredGenres.map((genre) {
                                      return ListTile(
                                        title: Text(genre),
                                        onTap: () => _addGenre(genre),
                                        dense: true,
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                            
                            SizedBox(height: 20),
                            
                            // Selected genres display
                            if (_selectedGenres.isNotEmpty) ...[
                              Text(
                                'Selected Genres:',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 12),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: _selectedGenres.map((genre) {
                                  return Chip(
                                    side: BorderSide(color: Color(0xFF81D4FA)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                    label: Text(genre),
                                    backgroundColor: Color(0xFFE0F7FA),
                                    deleteIcon: Icon(Icons.close),
                                    onDeleted: () => _removeGenre(genre),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom buttons section
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _skip,
                            child: Text(
                              'Skip',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _selectedGenres.isEmpty ? null : _continue,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              backgroundColor: _selectedGenres.isEmpty ? Colors.grey : Colors.white,
                              foregroundColor: Color(0xFF4277B8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                color: _selectedGenres.isEmpty ? Colors.grey[600] : Color(0xFF4277B8),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
