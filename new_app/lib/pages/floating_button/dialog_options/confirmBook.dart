import 'package:Lino_app/services/book_services.dart';
import 'package:flutter/material.dart';

class BookConfirmDialog extends StatefulWidget {
  final Future<Map<String, dynamic>> bookInfoFuture;

  const BookConfirmDialog({Key? key, required this.bookInfoFuture}) : super(key: key);

  @override
  _BookConfirmDialogState createState() => _BookConfirmDialogState();
}

class _BookConfirmDialogState extends State<BookConfirmDialog> {
  final BookService bookService = BookService();
  late Map<String, dynamic> editableBookInfo;
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FutureBuilder<Map<String, dynamic>>(
        future: widget.bookInfoFuture,
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

          editableBookInfo = snapshot.data!;
          final List<String> authors = editableBookInfo['authors'] != null
              ? List<String>.from(editableBookInfo['authors'])
              : [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Confirmation Form',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
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
                          child: editableBookInfo['coverImage'] != null
                              ? Image.network(
                                  editableBookInfo['coverImage']!,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 150,
                                      height: 200,
                                      color: Colors.grey,
                                      child: Center(
                                        child: Text(
                                          editableBookInfo['title'] ?? 'No Image',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Text('No Image Available'),
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow('Title', editableBookInfo['title'] ?? 'Unknown', 'title'),
                        SizedBox(height: 8),
                        _buildInfoRow('Author${authors.length > 1 ? 's' : ''}', authors.join(', '), 'authors'),
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
                        _buildInfoRow('Description', editableBookInfo['description'] ?? 'No description available.', 'description'),
                        SizedBox(height: 8),
                        _buildInfoRow('ISBN', editableBookInfo['isbn'] ?? 'No ISBN available', 'isbn'),
                        SizedBox(height: 8),
                        _buildInfoRow('Publisher', editableBookInfo['publisher'] ?? 'No publisher available', 'publisher'),
                        SizedBox(height: 8),
                        _buildInfoRow('Categories', editableBookInfo['categories']?.join(', ') ?? 'No categories available', 'categories'),
                        SizedBox(height: 8),
                        _buildInfoRow('Year', editableBookInfo['parutionYear']?.toString() ?? 'No year available', 'parutionYear'),
                        SizedBox(height: 8),
                        _buildInfoRow('Pages', editableBookInfo['pages']?.toString() ?? 'No page count available', 'pages'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        bookService.addBookToBB('rekjfghdvkjbfhekjhkj', '669d52d67ea5a6dc624fc4b6', 
                        isbn: editableBookInfo['isbn'], 
                        authors: editableBookInfo['author'], 
                        description: editableBookInfo['description'], 
                        publisher: editableBookInfo['publisher'],
                        parutionYear: editableBookInfo['parutionYear'],
                        title: editableBookInfo['title'],
                        pages: editableBookInfo['pages'],
                        coverImage: editableBookInfo['coverImage']
                        );
                      },
                      child: Text('Confirm'),
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

  Widget _buildInfoRow(String title, String content, String key) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(content, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            _editField(context, title, content, key);
          },
        ),
      ],
    );
  }

  void _editField(BuildContext context, String title, String currentValue, String key) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter new $title',
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  editableBookInfo[key] = controller.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
