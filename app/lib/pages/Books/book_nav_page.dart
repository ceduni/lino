import 'package:flutter/material.dart';
import 'package:Lino_app/services/book_services.dart';
import 'book_details_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final bookService = BookService();
  List<Map<String, dynamic>> bookBoxes = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadBookBoxes();
  }

  Future<void> _loadBookBoxes() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await bookService.searchBookboxes();
      setState(() {
        bookBoxes = List<Map<String, dynamic>>.from(
          data['bookboxes'].map((bookbox) => bookbox),
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Error: $error'))
          : RefreshIndicator(
        onRefresh: _loadBookBoxes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              for (var bb in bookBoxes) ...[
                Container(
                  width: double.infinity,
                  color: Color.fromRGBO(125, 200, 237, 1),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    bb['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  color: Color.fromRGBO(250, 250, 240, 1),
                  child: Container(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: bb['books'].length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => BookDetailsPage(
                                book: bb['books'][index],
                                bbid: bb['id'],
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(
                              bb['books'][index]['coverImage'],
                              errorBuilder: (BuildContext context,
                                  Object exception,
                                  StackTrace? stackTrace) {
                                return Container(
                                  color: Colors.grey,
                                  child: Center(
                                    child: Text(
                                      bb['books'][index]['title'],
                                      style: TextStyle(
                                          color: Colors.white),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
