import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/constants/colors.dart';

class FavouriteGenresPage extends StatefulWidget {
  @override
  _FavouriteGenresPageState createState() => _FavouriteGenresPageState();
}

class _FavouriteGenresPageState extends State<FavouriteGenresPage> {
  final TextEditingController _genreController = TextEditingController();
  final List<String> _selectedGenres = [];
  List<String> _availableGenres = [];
  List<String> _filteredGenres = [];
  bool _isLoading = true;
  bool _showSuggestions = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadBookGenres();
    _loadUserGenres();
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
      });
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
      
      setState(() {
        for (var item in favouriteGenres) {
          _selectedGenres.add(item);
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user genres: $e');
      setState(() {
        _isLoading = false;
      });
    }
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

  Future<void> _finish() async {
    try {
      var userService = UserService();
      await userService.updateUser(_token!, favouriteGenres: _selectedGenres);
      showToast('Favourite genres updated successfully!');
      Navigator.pop(context);
    } catch (e) {
      showToast('Error updating favourite genres: $e');
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

  void _pass() {
    Navigator.pop(context);
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(text);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(text);
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black),
        children: [
          if (index > 0)
            TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          if (index + query.length < text.length)
            TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4277B8),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Setup Favourite Genres'),
        backgroundColor: Color(0xFF4277B8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
                            'Tell us your favourite genres:',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Select your favourite book genres to get personalized recommendations and notifications',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    // Input section with autocomplete
                    Column(
                      children: [
                        Row(
                          children: [
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
                            margin: EdgeInsets.only(top: 8),
                            height: 200, // Fixed height for scrolling
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
                            child: ListView.builder(
                              itemCount: _filteredGenres.length,
                              itemBuilder: (context, index) {
                                final genre = _filteredGenres[index];
                                final query = _genreController.text.toLowerCase();
                                return ListTile(
                                  title: _buildHighlightedText(genre, query),
                                  onTap: () => _addGenre(genre),
                                  dense: true,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Selected genres display section
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        child: Wrap(
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
                      ),
                    ),
                    
                    // Bottom buttons section
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _pass,
                            child: Text(
                              'Pass',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _finish,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              backgroundColor: LinoColors.buttonPrimary,
                            ),
                            child: Text(
                              'Finished!',
                              style: TextStyle(color: Colors.white),
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
