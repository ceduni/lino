// book_cover.dart
import 'package:flutter/material.dart';
import 'package:Lino_app/pages/book_details_page.dart';

class BookCover extends StatelessWidget {
  final String bookId;
  final String coverImageUrl;
  final String bookBoxId;

  BookCover({
    required this.bookId, 
    required this.coverImageUrl,
    required this.bookBoxId
    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsPage(
              qrCode: bookId,
              bookBoxId: bookBoxId,
              ),
          ),
        );
      },
      child: Image.network(coverImageUrl),
    );
  }
}
