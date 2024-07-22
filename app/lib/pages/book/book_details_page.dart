import 'package:flutter/material.dart';

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
            Image.network(book['coverImage']),
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
}
