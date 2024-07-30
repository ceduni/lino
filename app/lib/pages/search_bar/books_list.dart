// books_list.dart
import 'package:flutter/material.dart';
import 'package:Lino_app/services/book_services.dart';

class BooksList extends StatelessWidget {
  final String query;

  BooksList({required this.query});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: BookService().searchBooks(kw: query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!['books'].isEmpty) {
          return Center(child: Text('No books found.'));
        }

        final books = snapshot.data!['books'];
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(books[index]['title']),
              subtitle: Text(books[index]['authors'].join(', ')),
            );
          },
        );
      },
    );
  }
}
