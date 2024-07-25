import 'package:flutter/material.dart';

class NoISBNDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('No ISBN'),
      content: Text('This is the "I don\'t have the book ISBN" dialog box.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }
}
