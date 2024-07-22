import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookDetailsPage extends StatefulWidget {
  final Map<String, dynamic> book;

  BookDetailsPage({required this.book});

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  late Map<String, dynamic> book;

  @override
  void initState() {
    super.initState();
    book = widget.book;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(book['title'], style: TextStyle(fontSize: 24)),
            Text('Authors: ${book['authors'].join(', ')}'),
            FutureBuilder<bool>(
              future: _isValidImageUrl(book['coverImage']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasData && snapshot.data == true) {
                  return Image.network(book['coverImage']);
                } else {
                  return Container(
                    width: 200,
                    height: 300,
                    color: Colors.grey,
                    child: Center(
                      child: Text(
                        book['title'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            Text(book['description']),
            Text('ISBN: ${book['isbn']}'),
            Text('Publisher: ${book['publisher']}'),
            Text('Categories: ${book['categories'].join(', ')}'),
            Text('Year: ${book['parutionYear']}'),
            Text('Pages: ${book['pages']}'),
          ],
        ),
      ),
    );
  }

  Future<bool> _isValidImageUrl(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
