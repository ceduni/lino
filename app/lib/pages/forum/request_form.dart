import 'package:Lino_app/services/book_request_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class RequestFormPage extends StatefulWidget {
  final VoidCallback onRequestCreated;

  const RequestFormPage({required this.onRequestCreated, Key? key}) : super(key: key);

  @override
  _RequestFormPageState createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<RequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  bool _showSuggestions = false;
  bool _isLoadingSuggestions = false;
  List<BookSuggestion> _suggestions = [];
  Timer? _debounceTimer;
  BookSuggestion? _selectedSuggestion;
  bool _isCustomTitle = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _focusNode.removeListener(_onFocusChanged);
    _titleController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTitleChanged() {
    final query = _titleController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _suggestions.clear();
        _selectedSuggestion = null;
        _isCustomTitle = false;
      });
      return;
    }

    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Start new timer for debounced search
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      _searchBookSuggestions(query);
    });
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Hide suggestions when focus is lost
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  Future<void> _searchBookSuggestions(String query) async {
    if (query.length < 2) return;

    setState(() {
      _isLoadingSuggestions = true;
      _showSuggestions = true;
    });

    try {
      final suggestions = await BookRequestService().getBookSuggestions(query, limit: 10);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      print('Error searching suggestions: $e');
      if (mounted) {
        setState(() {
          _suggestions.clear();
          _isLoadingSuggestions = false;
        });
        // Show error dialog instead of toast
        _showErrorDialog('Search Error', 'Failed to search for books: ${e.toString()}');
      }
    }
  }

  void _selectSuggestion(BookSuggestion suggestion) {
    setState(() {
      _selectedSuggestion = suggestion;
      _titleController.text = suggestion.title;
      _showSuggestions = false;
      _isCustomTitle = false;
    });
    _focusNode.unfocus();
  }

  void _useCustomTitle() {
    setState(() {
      _selectedSuggestion = null;
      _showSuggestions = false;
      _isCustomTitle = true;
    });
    _focusNode.unfocus();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try { 
        final token = await SharedPreferences.getInstance().then((prefs) => prefs.getString('token'));
        await BookRequestService().requestBookToUsers(
          token!,
          _titleController.text,
          cm: _messageController.text,
        );

        widget.onRequestCreated();  // Call the callback to re-fetch requests

        if (mounted) {
          Navigator.of(context).pop(); // Go back to previous page
          _showSuccessSnackBar('Request sent successfully! 📚');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar('Failed to send request: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 235, 1),
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: const Text(
          'Create Book Request',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(101, 67, 33, 1),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header text
                Text(
                  'What book are you looking for?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kanit',
                    color: Color.fromRGBO(101, 67, 33, 1),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Search for a book or enter a custom title to request it from other users.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Kanit',
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24),
            // Book Title Field with Autocomplete
            TextFormField(
              controller: _titleController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: 'Book Title',
                suffixIcon: _isLoadingSuggestions 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the title of the book';
                }
                return null;
              },
              onTap: () {
                if (_suggestions.isNotEmpty && _titleController.text.isNotEmpty) {
                  setState(() {
                    _showSuggestions = true;
                  });
                }
              },
            ),
            
            // Suggestions List (below the text field)
            if (_showSuggestions && (_suggestions.isNotEmpty || _isLoadingSuggestions))
              Container(
                margin: EdgeInsets.only(top: 4, bottom: 8),
                constraints: BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: _isLoadingSuggestions
                    ? Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Searching for books...'),
                            ],
                          ),
                        ),
                      )
                    : _suggestions.isEmpty
                        ? Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off, color: Colors.grey, size: 32),
                                SizedBox(height: 8),
                                Text(
                                  'No suggestions found',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _useCustomTitle,
                                  icon: Icon(Icons.edit, size: 16),
                                  label: Text('Use custom title'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.lightbulb, color: Colors.blue, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      'Select a book or use custom title:',
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Suggestions list
                              Flexible(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: _suggestions.length + 1, // +1 for custom option
                                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                                  itemBuilder: (context, index) {
                                    if (index == _suggestions.length) {
                                      // Custom title option
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: ListTile(
                                          leading: Icon(Icons.edit, color: Colors.orange),
                                          title: Text(
                                            'Use custom title',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.orange.shade800,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Continue with "${_titleController.text}"',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange.shade700,
                                            ),
                                          ),
                                          onTap: _useCustomTitle,
                                          dense: true,
                                        ),
                                      );
                                    }
                                    
                                    final suggestion = _suggestions[index];
                                    return ListTile(
                                      leading: Icon(Icons.book, color: Colors.blue),
                                      title: Text(
                                        suggestion.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      subtitle: Text(
                                        'by ${suggestion.author}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      onTap: () => _selectSuggestion(suggestion),
                                      dense: true,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
              ),
            
            // Warning for custom titles (only show when not in suggestions mode)
            if (_isCustomTitle && _selectedSuggestion == null && !_showSuggestions)
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Using a custom title may reduce your chances of being notified when this book becomes available.',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            SizedBox(height: 16),
            
            // Selected book info
            if (_selectedSuggestion != null)
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected: ${_selectedSuggestion!.title}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          Text(
                            'by ${_selectedSuggestion!.author}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Custom Message Field
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Custom Message (optional)'),
              maxLines: 3,
              minLines: 1,
            ),
            
            SizedBox(height: 16),
            
                // Submit Button
                SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromRGBO(101, 67, 33, 1),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(101, 67, 33, 1),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            'Send Request',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Kanit',
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
