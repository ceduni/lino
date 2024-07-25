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
  Future<List<String>>? namesFuture;
  String? selectedName;

  @override
  void initState() {
    super.initState();
    namesFuture = fetchNames();
  }

  Future<List<String>> fetchNames() async {
    var bookboxes = await bookService.searchBookboxes();
    List<String> names = [];
    if (bookboxes.containsKey('bookboxes')) {
      names = bookboxes['bookboxes'].map<String>((bb) => bb['name'].toString()).toList();
    }
    return names;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Enter book ISBN',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: Column(
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
          SizedBox(height: 8),
          FutureBuilder<List<String>>(
            future: namesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error loading names');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No names available');
              } else {
                return DropdownButton<String>(
                  isExpanded: true,
                  value: selectedName,
                  hint: Text('Select a name'),
                  items: snapshot.data!.map((String name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedName = newValue;
                    });
                  },
                );
              }
            },
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final isbn = isbnController.text;
              if (RegExp(r'^\d{13}$').hasMatch(isbn) && selectedName != null) {
                // Handle valid ISBN input and selected name
                // Add book to the database
                final bookService = BookService();
                bookService.addBookToBB(isbn, '669d52d67ea5a6dc624fc4b6');

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
    );
  }
}
