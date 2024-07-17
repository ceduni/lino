import 'package:Lino_app/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:Lino_app/services/book_services.dart';

class BookDetailsPage extends StatefulWidget {
  final String qrCode;
  final String bookBoxId;

  BookDetailsPage({required this.qrCode, required this.bookBoxId});

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  late Future<Map<String, dynamic>> book;
  final bookService = BookService();

  @override
  void initState() {
    super.initState();
    book = bookService.getBookFromBB(widget.qrCode, widget.bookBoxId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
      ),
      body: FutureBuilder<Book>(
        future: book,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Book not found'));
          } else {
            var book = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Text(book.title, style: TextStyle(fontSize: 24)),
                  Text('Authors: ${book.authors.join(', ')}'),
                  Image.network(book.coverImage),
                  Text(book.description),
                  Text('ISBN: ${book.isbn}'),
                  Text('Publisher: ${book.publisher}'),
                  Text('Categories: ${book.categories.join(', ')}'),
                  Text('Year: ${book.parutionYear}'),
                  Text('Pages: ${book.pages}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
