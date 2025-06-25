import 'package:flutter/material.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/constants/colors.dart';

class NotificationKeywordsPage extends StatefulWidget {
  @override
  _NotificationKeywordsPageState createState() => _NotificationKeywordsPageState();
}

class _NotificationKeywordsPageState extends State<NotificationKeywordsPage> {
  final TextEditingController _keywordController = TextEditingController();
  final List<String> _keywords = [];
  bool _isLoading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadUserKeywords();
  }

  Future<void> _loadUserKeywords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      if (_token == null) throw Exception('No token found');

      final userService = UserService();
      final user = await userService.getUser(_token!);
      final keyWords = user['user']?['notificationKeyWords'];
      
      setState(() {
        if (keyWords != null) {
          if (keyWords is List) {
            // Handle list of strings or mixed types
            for (var item in keyWords) {
              if (item != null) {
                _keywords.add(item.toString());
              }
            }
          } else if (keyWords is String && keyWords.isNotEmpty) {
            // Handle comma-separated string
            _keywords.addAll(keyWords.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty));
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user keywords: $e');
      // Don't show toast for new users - this is expected
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addKeyword() {
    final keyword = _keywordController.text.trim();
    if (keyword.isNotEmpty && !_keywords.contains(keyword)) {
      setState(() {
        _keywords.add(keyword);
        _keywordController.clear();
      });
    }
  }

  void _removeKeyword(String keyword) {
    setState(() {
      _keywords.remove(keyword);
    });
  }

  Future<void> _finish() async {
    final keyWords = _keywords.join(',');

    try {
      var us = UserService();
      await us.updateUser(_token!, keyWords: keyWords);
      showToast('User preferences updated successfully!');
      Navigator.pop(context);
    } catch (e) {
      showToast('Error updating user preferences: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4277B8), // Same blue background
      appBar: AppBar(
        title: Text('Setup Notification Keywords'),
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
                            'Tell us what you like:',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Input as many keywords as you want to be notified when a book relevant to your preferences appears in the book network',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    // Input section
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _keywordController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              hintText: 'Enter keyword',
                              hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                              filled: true,
                              fillColor: Color(0xFFE0F7FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) => _addKeyword(),
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.white),
                          onPressed: _addKeyword,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Keywords display section
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: _keywords.map((keyword) {
                            return Chip(
                              side: BorderSide(color: Color(0xFF81D4FA)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                              label: Text(keyword),
                              backgroundColor: Color(0xFFE0F7FA),
                              deleteIcon: Icon(Icons.close),
                              onDeleted: () => _removeKeyword(keyword),
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
