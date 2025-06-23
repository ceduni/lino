import 'package:Lino_app/pages/floating_button/common/build_banner.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:Lino_app/services/bookbox_state_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookConfirmDialog extends StatefulWidget {
  final Future<Map<String, dynamic>> bookInfoFuture;
  final String bookBoxId;

  const BookConfirmDialog({
    super.key,
    required this.bookInfoFuture,
    required this.bookBoxId,
  });

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
        color: const Color.fromRGBO(250, 250, 240, 0.9),
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
        color: const Color.fromRGBO(244, 226, 193, 0.9),
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
      print('Categories: ${editableBookInfo['categories']}');
      final cat = List<String>.from(editableBookInfo['categories'] ?? []);
      if (cat.isEmpty) {
        cat.add('Unknown category');
      }

      print('Authors: ${editableBookInfo['authors']}');
      final authors = List<String>.from(editableBookInfo['authors'] ?? []);

      // Directly add the book to the bookbox
      await BookService().addBookToBB(
        widget.bookBoxId,
        token: token,
        isbn: editableBookInfo['isbn'],
        title: editableBookInfo['title'],
        authors: authors,
        description: editableBookInfo['description'],
        coverImage: editableBookInfo['coverImage'],
        publisher: editableBookInfo['publisher'],
        parutionYear: editableBookInfo['parutionYear'],
        pages: editableBookInfo['pages'],
        categories: cat,
      );

      // Trigger refresh for all bookbox displays
      BookBoxStateService.instance.triggerRefresh();
      
      // Show success message
      showToast('Book has been successfully added to the Book Box.');
      
      // Close all dialogs and return to main screen
      Get.back(); // Close current dialog
      Get.back(); // Close previous dialog
      Get.back(); // Close bookbox selection dialog
      
    } catch (e) {
      print('Error adding book: $e');
      Get.snackbar('Error', 'Failed to add book: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
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
            keyboardType: (key == 'parutionYear' || key == 'pages') 
                ? TextInputType.number 
                : TextInputType.text,
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
                  if (key == 'authors' || key == 'categories') {
                    // Handle list fields
                    editableBookInfo[key] = controller.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                  } else if (key == 'parutionYear' || key == 'pages') {
                    // Handle integer fields
                    final intValue = int.tryParse(controller.text.trim());
                    editableBookInfo[key] = intValue;
                  } else {
                    // Handle string fields
                    final stringValue = controller.text.trim();
                    editableBookInfo[key] = stringValue.isNotEmpty ? stringValue : null;
                  }
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
