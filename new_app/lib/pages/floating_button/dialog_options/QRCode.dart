import 'package:flutter/material.dart';
import 'package:Lino_app/services/book_services.dart';
import 'barcode_scanner.dart';

class ISBNQRCodeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: BarcodeScanner(
        submitAction: (qrCode) {
          // Add book to the database or handle the scanned QR code
          final bookService = BookService();
          bookService.addBookToBB(qrCode, '669d52d67ea5a6dc624fc4b6');

          // Close the dialog after scanning
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
