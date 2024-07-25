import 'package:flutter/material.dart';

class BookConfirmDialog extends StatelessWidget {
  final Future<Map<String, dynamic>> bookInfoFuture;

  const BookConfirmDialog({Key? key, required this.bookInfoFuture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FutureBuilder<Map<String, dynamic>>(
        future: bookInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Error: ${snapshot.error}'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return AlertDialog(
              title: Text('No Data'),
              content: Text('No book information available.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          }

          final bookInfo = snapshot.data!;
          final List<String> authors = bookInfo['authors'] != null
              ? List<String>.from(bookInfo['authors'])
              : [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Container for the book cover, title, and author
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
                          child: bookInfo['coverImage'] != null
                              ? Image.network(
                                  bookInfo['coverImage']!,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 150,
                                      height: 200,
                                      color: Colors.grey,
                                      child: Center(
                                        child: Text(
                                          bookInfo['title'] ?? 'No Image',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Text('No Image Available'),
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow('Title', bookInfo['title'] ?? 'Unknown'),
                        SizedBox(height: 8),
                        _buildInfoRow('Author${authors.length > 1 ? 's' : ''}', authors.join(', ')),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Container for the book description and other details
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(244, 226, 193, 1).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Description', bookInfo['description'] ?? 'No description available.'),
                        SizedBox(height: 8),
                        _buildInfoRow('ISBN', bookInfo['isbn'] ?? 'No ISBN available'),
                        SizedBox(height: 8),
                        _buildInfoRow('Publisher', bookInfo['publisher'] ?? 'No publisher available'),
                        SizedBox(height: 8),
                        _buildInfoRow('Categories', bookInfo['categories']?.join(', ') ?? 'No categories available'),
                        SizedBox(height: 8),
                        _buildInfoRow('Year', bookInfo['parutionYear']?.toString() ?? 'No year available'),
                        SizedBox(height: 8),
                        _buildInfoRow('Pages', bookInfo['pages']?.toString() ?? 'No page count available'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 4),
        Text(content, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}
