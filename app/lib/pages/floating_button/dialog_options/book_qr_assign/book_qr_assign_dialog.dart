import 'package:Lino_app/pages/floating_button/common/build_scanner.dart';
import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/book_qr_assign/book_qr_assign_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/form_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Lino_app/pages/floating_button/common/build_banner.dart';

class BookQRAssignDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final barcodeController = Get.put(BarcodeController());
    Get.lazyPut(() => FormController());
    Get.lazyPut(() => BookQRAssignController());

    return Dialog(
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildBanner(context, 'Scan QR Code'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Scan the book's new QR code"),
                  SizedBox(height: 16.0),
                  buildScanner(barcodeController),
                  SizedBox(height: 16.0),
                  _buildSubmitButton(),
                  SizedBox(height: 16.0),
                  Obx(() =>
                      Text(Get.find<BarcodeController>().barcodeObs.value)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        var barcode = Get.find<BarcodeController>().barcodeObs.value;
        Get.find<FormController>().setSelectedQRCode(barcode);
        print('QR code: $barcode');
        Get.find<BookQRAssignController>().submitQRCode();
      },
      child: Text('Submit'),
    );
  }
}
