import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Books/book_details_page.dart';

class BookInBookBoxRow extends StatelessWidget {
  final List<Map<String, dynamic>> books;

  const BookInBookBoxRow({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12), // Replace with your border radius constant
        color: const Color.fromARGB(255, 242, 226, 196),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: books.map((book) => _buildBookItem(context, book)).toList(),
        ),
      ),
    );
  }

  Widget _buildBookItem(BuildContext context, Map<String, dynamic> book) {
    String bookName = book['title'] + ' by ' + book['authors'].join(', ');

    return GestureDetector(
      onTap: () => _navigateToBookDetails(context, book),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        width: 100,
        child: Column(
          children: [
            _buildBookCover(book),
            Text(
              bookName,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }

  void _navigateToBookDetails(BuildContext context, Map<String, dynamic> book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(book: book),
      ),
    );
  }

  Widget _buildBookCover(Map<String, dynamic> book) {
    return Container(
      width: 100, // Adjust the width and height as necessary
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: Image.network(book['coverImage']!).image,
          fit: BoxFit.cover,
          onError: (Object exception, StackTrace? stackTrace) {
            DecorationImage(
              image: const NetworkImage(
                  'https://placehold.co/100x160.png'), // Path to a placeholder image in your assets
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}