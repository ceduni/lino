import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/book_services.dart';
import '../../services/thread_services.dart';

class AddThreadForm extends StatefulWidget {
  @override
  _AddThreadFormState createState() => _AddThreadFormState();
}

class _AddThreadFormState extends State<AddThreadForm> {
  final _formKey = GlobalKey<FormState>();
  final _bookSearchController = TextEditingController();
  final _titleController = TextEditingController();
  bool _isLoading = false;
  Timer? _debounce;
  List<dynamic> books = [];
  String? selectedBookId;

  @override
  void initState() {
    super.initState();
    _bookSearchController.addListener(_onSearchChanged);
    _searchBooks(null); // Call to display all books by default
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _bookSearchController.removeListener(_onSearchChanged);
    _bookSearchController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 750), () {
      _searchBooks(_bookSearchController.text.isEmpty ? null : _bookSearchController.text);
    });
  }

  Future<void> _searchBooks(String? query) async {
    try {
      var bs = BookService();
      var response = await bs.searchBooks(kw: query);
      print('Search response: $response'); // Debug print
      setState(() {
        books = response['books'];
      });
    } catch (e) {
      print('Error searching books: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && selectedBookId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        var token = await SharedPreferences.getInstance().then((prefs) => prefs.getString('token'));
        var ts = ThreadService();
        await ts.createThread(token!, selectedBookId!, _titleController.text);

        Navigator.of(context).pop(); // Close the modal

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thread created successfully!')),
        );
      } catch (e) {
        Navigator.of(context).pop(); // Close the modal if there's an error

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose a book', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _bookSearchController,
              decoration: InputDecoration(labelText: 'Search for a book'),
            ),
            if (books.isNotEmpty)
              Container(
                height: 120, // Increase the container height
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final isSelected = book['_id'] == selectedBookId;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBookId = book['_id'];
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            width: isSelected ? 4 : 2,
                          ),
                          borderRadius: BorderRadius.circular(isSelected ? 12.0 : 8.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(isSelected ? 12.0 : 8.0),
                          child: Container(
                            width: isSelected ? 120 : 100, // Increase width for selected book
                            height: isSelected ? 120 : 100, // Increase height for selected book
                            color: Colors.grey.shade200, // Placeholder color
                            child: book['coverImage'] != null
                                ? Image.network(
                              book['coverImage'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey,
                                  child: Center(
                                    child: Text(
                                      book['title'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                                : Container(
                              color: Colors.grey,
                              child: Center(
                                child: Text(
                                  book['title'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submitForm,
              child: Text('Create Thread'),
            ),
          ],
        ),
      ),
    );
  }
}


