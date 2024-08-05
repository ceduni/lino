import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Widget buildScanner(BarcodeController barcodeController) {
  return Container(
    height: 200,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
      color: Colors.grey[300],
    ),
    child: MobileScanner(
      controller: barcodeController.scannerController,
      fit: BoxFit.contain,
    ),
  );
}
