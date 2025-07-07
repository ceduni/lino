import 'package:flutter/material.dart';

class BookBoxAction extends StatelessWidget {
  final String bookBoxId;

  const BookBoxAction({Key? key, required this.bookBoxId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(); // Close the dialog when tapping outside
      },
      child: Scaffold(
        backgroundColor: Colors.black54, // Semi-transparent background
        body: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping inside the dialog
            child: Container(
              width: 300,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Book Box Action',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Book Box ID: $bookBoxId'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Perform action here
                    },
                    child: Text('Perform Action'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
