import 'package:flutter/material.dart';
import 'dialog_options/with_ISBN.dart';
import 'dialog_options/QRCode.dart';
import 'dialog_options/no_ISBN.dart';

class AddBookDialog extends StatelessWidget {
  final String qrCode;

  AddBookDialog({required this.qrCode});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.only(left: 8.0, top: 8.0),
      title: Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => ISBNCodeDialog(),
              );
            },
            child: Text('I have the book ISBN'),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => NoISBNDialog(),
              );
            },
            child: Text('I don\'t have the book ISBN'),
          ),
        ],
      ),
    );
  }
}
