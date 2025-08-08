import 'package:Lino_app/models/book_model.dart';
import 'package:flutter/material.dart';

import '../books/book_details_page.dart';

class BookInBookBoxRow extends StatelessWidget {
  final List<Book> books;
  final String bbid;

  const BookInBookBoxRow({super.key, required this.books, required this.bbid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(
            12), 
        color: const Color.fromARGB(255, 242, 226, 196),
      ),
      child: Column(
        children: [
          const Text(
            'Books in this Book Box',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Kanit'),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: books.map((book) {
              return _buildBookItem(context, book);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(BuildContext context, Book book) {
    String title = book.title; 
    List<String> authors = book.authors;
    String authorsString = authors.isNotEmpty ? authors.join(', ') : 'Unknown Author';
    String bookName = '$title by $authorsString';

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

  void _navigateToBookDetails(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => BookDetailsPage(book: book, bbid: bbid),
    );
  }

  Widget _buildBookCover(Book book) {
    String? coverImage = book.coverImage;
    String title = book.title;

    return SizedBox(
      width: 100, // Define the width
      height: 150, // Define the height
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: coverImage != null && coverImage.isNotEmpty
            ? Image.network(
                coverImage,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return Container(
                    width: 100,
                    height: 150,
                    color: Colors.grey,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: null,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container(
                width: 100,
                height: 150,
                color: Colors.grey,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: null,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
