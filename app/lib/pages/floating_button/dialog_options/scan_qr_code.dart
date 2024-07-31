import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'with_ISBN.dart';

class ScanQRCode extends StatefulWidget {
  @override
  _ScanQRCodeState createState() => _ScanQRCodeState();
}

class _ScanQRCodeState extends State<ScanQRCode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      setState(() {
        qrText = scanData.code; // This contains the raw text from the QR code
      });
      Navigator.of(context).pop(qrText); // Pass the scanned data back
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Scan the QR code of the book'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan a QR code'),
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (context) => ISBNCodeDialog(),
            );
          },
          child: Text('Enter ISBN Manually'),
        ),
      ],
    );
  }
}