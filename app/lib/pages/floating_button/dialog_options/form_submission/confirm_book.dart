import 'package:Lino_app/pages/floating_button/common/build_banner.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookConfirmDialog extends StatefulWidget {
  final Future<Map<String, dynamic>> bookInfoFuture;
  final String bookBoxId;
  final String bookQrCode;

  const BookConfirmDialog({
    Key? key,
    required this.bookInfoFuture,
    required this.bookBoxId,
    required this.bookQrCode,
  }) : super(key: key);

  @override
  _BookConfirmDialogState createState() => _BookConfirmDialogState();
}

class _BookConfirmDialogState extends State<BookConfirmDialog> {
  final BookService bookService = BookService();
  late Map<String, dynamic> editableBookInfo;
  bool isEditing = false;
  bool isLoading = false;

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
            return _buildErrorDialog(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data == null) {
            return _buildNoDataDialog();
          }

          editableBookInfo = snapshot.data!;
          return _buildDialogContent();
        },
      ),
    );
  }

  Widget _buildErrorDialog(String errorMessage) {
    return AlertDialog(
      title: Text('Error'),
      content: Text('Error: $errorMessage'),
      actions: <Widget>[
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildNoDataDialog() {
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

  Widget _buildDialogContent() {
    final List<String> authors = editableBookInfo['authors'] != null
        ? List<String>.from(editableBookInfo['authors'])
        : [];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildBanner(context, 'Confirm Book Details'),
            SizedBox(height: 16),
            _buildBookDetailsContainer(authors),
            SizedBox(height: 16),
            _buildBookInfoContainer(),
            SizedBox(height: 16),
            isLoading ? CircularProgressIndicator() : _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookDetailsContainer(List<String> authors) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(250, 250, 240, 1).withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildBookCoverImage()),
          SizedBox(height: 8),
          _buildInfoRow(
              'Title', editableBookInfo['title'] ?? 'Unknown', 'title'),
          SizedBox(height: 8),
          _buildInfoRow('Author${authors.length > 1 ? 's' : ''}',
              authors.join(', '), 'authors'),
        ],
      ),
    );
  }

  Widget _buildBookCoverImage() {
    return editableBookInfo['coverImage'] != null
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
        : Text('No Image Available');
  }

  Widget _buildBookInfoContainer() {
    final List<String> categories = editableBookInfo['categories'] != null
        ? List<String>.from(editableBookInfo['categories'])
        : [];

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(244, 226, 193, 1).withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
              'Description',
              editableBookInfo['description'] ?? 'No description available.',
              'description'),
          SizedBox(height: 8),
          _buildInfoRow(
              'ISBN', editableBookInfo['isbn'] ?? 'No ISBN available', 'isbn'),
          SizedBox(height: 8),
          _buildInfoRow(
              'Publisher',
              editableBookInfo['publisher'] ?? 'No publisher available',
              'publisher'),
          SizedBox(height: 8),
          _buildInfoRow(
              'Categories',
              categories.isNotEmpty? categories.join(', ') :
                  'No categories available',
              'categories'),
          SizedBox(height: 8),
          _buildInfoRow(
              'Year',
              editableBookInfo['parutionYear']?.toString() ??
                  'No year available',
              'parutionYear'),
          SizedBox(height: 8),
          _buildInfoRow(
              'Pages',
              editableBookInfo['pages']?.toString() ??
                  'No page count available',
              'pages'),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Center(
      child: ElevatedButton(
        onPressed: isLoading ? null : _onConfirmPressed,
        child: Text('Confirm'),
      ),
    );
  }

  Future<void> _onConfirmPressed() async {
    setState(() {
      isLoading = true;
    });

    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    try {
      await bookService.addBookToBB(
        widget.bookQrCode,
        widget.bookBoxId,
        token: token,
        isbn: editableBookInfo['isbn'],
        authors: List<String>.from(editableBookInfo['authors']),
        description: editableBookInfo['description'],
        publisher: editableBookInfo['publisher'],
        parutionYear: editableBookInfo['parutionYear'],
        title: editableBookInfo['title'],
        pages: editableBookInfo['pages'],
        coverImage: editableBookInfo['coverImage'],
        categories: List<String>.from(editableBookInfo['categories']),
      );
      Get.back();
    } catch (e) {
      print('Error adding book: $e');
      // Optionally, show an error message to the user
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
          onPressed: () => _editField(context, title, content, key),
        ),
      ],
    );
  }

  void _editField(
      BuildContext context, String title, String currentValue, String key) {
    TextEditingController controller =
    TextEditingController(text: currentValue);
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
                  editableBookInfo[key] = (key == 'authors' || key == 'categories') ? controller.text.split(',') : controller.text;
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
