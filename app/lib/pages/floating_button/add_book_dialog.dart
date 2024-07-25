import 'package:flutter/material.dart';
import 'dialog_options/with_ISBN.dart';
import 'dialog_options/QRCode.dart';
import 'dialog_options/no_ISBN.dart';

class AddBookDialog extends StatelessWidget {
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
            child: Text('ISBN Code'),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ISBNQRCodeDialog()),
              );
            },
            child: Text('ISBN via QR Code'),
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
