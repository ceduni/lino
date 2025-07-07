import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../nav_menu.dart';
import './add_thread_form.dart';
import '../../services/user_services.dart';
import 'expandable_text.dart';

class BookDetailsPage extends StatefulWidget {
  final Map<String, dynamic> book;
  final String bbid;

  BookDetailsPage({required this.book, required this.bbid});

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  bool _isLoading = true;
  bool _isUserLoggedIn = false;
  bool _isCheckingUser = true;  // New flag to check if user status is being checked

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }


  Future<void> _checkUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final user = await UserService().getUser(token);
      setState(() {
        _isUserLoggedIn = user['user'] != null && user['user'].isNotEmpty;
      });
    }
    setState(() {
      _isCheckingUser = false;
      _isLoading = false;  // Set loading to false when done checking user
    });
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

  void _showAddThreadForm(BuildContext context, String bookId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddThreadForm(bookId: bookId),
    );
  }



  void _navigateToForumPage() {
    final controller = Get.find<NavigationController>();
    controller.navigateToForumWithQuery(widget.book['title']);
    Navigator.of(context).pop(); // Close the dialog
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: _isLoading || _isCheckingUser
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(250, 250, 240, 1).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.network(
                        widget.book['coverImage'],
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                          return Container(
                            width: 150,
                            height: 200,
                            color: Colors.grey,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.book['title'],
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    ),
                    SizedBox(height: 8),
                    Text(widget.book['title'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Text('Authors: ${widget.book['authors'].join(', ')}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    if (_isUserLoggedIn)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                            ),
                            onPressed: () {
                              _showAddThreadForm(context, widget.book['_id']);
                            },
                            child: Text('+ Add Thread', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(244, 226, 193, 1).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Kanit')),
                    SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(250, 250, 240, 1).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: ExpandableText(widget.book['description']),
                    ),
                    SizedBox(height: 16),
                    Text('ISBN: ${widget.book['isbn']}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Text('Publisher: ${widget.book['publisher']}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Text('Categories: ${widget.book['categories'].join(', ')}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Text('Year: ${widget.book['parutionYear']}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 8),
                    Text('Pages: ${widget.book['pages']}', style: TextStyle(fontSize: 16, fontFamily: 'Kanit')),
                    SizedBox(height: 10),
                    if (_isUserLoggedIn)
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.green.shade700,
                          ),
                          onPressed: _navigateToForumPage,
                          child: Text('View Threads in Forum'),
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
