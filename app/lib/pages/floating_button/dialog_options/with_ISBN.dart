import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Lino_app/services/book_services.dart';

class ISBNCodeDialog extends StatefulWidget {
  @override
  _ISBNCodeDialogState createState() => _ISBNCodeDialogState();
}

class _ISBNCodeDialogState extends State<ISBNCodeDialog> {
  final TextEditingController isbnController = TextEditingController();
  final BookService bookService = BookService();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: const Color.fromARGB(255, 10, 79, 135), // Deep blue banner color
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop(); // Go back to the previous dialog
                  },
                ),
                Expanded(
                  child: Text(
                    'Enter book ISBN',
                    style: TextStyle(
                      fontSize: 20  ,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White title text
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: isbnController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'QR Code',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13), // Limits input to 13 digits
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    final isbn = isbnController.text;
                    if (RegExp(r'^\d{13}$').hasMatch(isbn)) {
                      // Handle valid ISBN input and selected name
                      late Future<Map<String, dynamic>> bookInfo = bookService.getBookInfo(isbn);

                      // Close the dialog
                      Navigator.of(context).pop();
                    } else {
                      // Show error if ISBN is not valid or name is not selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid ISBN or no name selected.')),
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
