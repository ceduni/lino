import 'package:flutter/material.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeywordInputPage extends StatefulWidget {
  final String username;
  final String token;
  final SharedPreferences prefs;

  const KeywordInputPage({required this.username, required this.token, required this.prefs, super.key});

  @override
  _KeywordInputPageState createState() => _KeywordInputPageState();
}

class _KeywordInputPageState extends State<KeywordInputPage> {
  final TextEditingController _keywordController = TextEditingController();
  final List<String> _keywords = [];

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

  void _finish() async {
    final keyWords = _keywords.join(',');

    try {
      var us = UserService();
      await us.updateUser(widget.token, keyWords: keyWords);

      showToast('User preferences updated successfully!');

      Navigator.pushReplacementNamed(context, '/home');
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
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4277B8), // Same blue background
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20), // Add bottom margin
                    child: TextField(
                      controller: _keywordController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Adjust padding
                        hintText: 'Enter keyword',
                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Less opaque placeholder text
                        filled: true,
                        fillColor: Color(0xFFE0F7FA), // Clearer blue background
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0), // Rounded borders
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20), // Match the bottom margin of the TextField
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _addKeyword,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _keywords.map((keyword) {
                return Chip(
                  side: BorderSide(color: Color(0xFF81D4FA)), // Lighter blue border
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)), // Rounded corners
                  label: Text(keyword),
                  backgroundColor: Color(0xFFE0F7FA), // Clearer blue background
                  deleteIcon: Icon(Icons.close),
                  onDeleted: () => _removeKeyword(keyword),
                );
              }).toList(),
            ),
            Spacer(),
            Row(
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
                  ),
                  child: Text('Finished!'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
