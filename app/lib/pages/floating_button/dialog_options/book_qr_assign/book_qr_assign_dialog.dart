import 'package:Lino_app/pages/floating_button/common/build_scanner.dart';
import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/book_qr_assign/book_qr_assign_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/form_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Lino_app/pages/floating_button/common/build_banner.dart';

class BookQRAssignDialog extends StatelessWidget {
  final bool isAddBook;

  const BookQRAssignDialog({super.key, required this.isAddBook});

  @override
  Widget build(BuildContext context) {
    final BarcodeController barcodeController = Get.put(BarcodeController());
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
                  isAddBook? const Text("Scan the book's new QR code") : const Text("Scan the chosen book's QR code"),
                  const SizedBox(height: 16.0),
                  buildScanner(barcodeController),
                  const SizedBox(height: 16.0),
                  _buildSubmitButton(),
                  const SizedBox(height: 16.0),
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
        if (isAddBook) {
          final String barcode = Get.find<BarcodeController>().barcodeObs.value;
          if (barcode.isEmpty || barcode == '') {
            return;
          }
          Get.find<FormController>().setSelectedQRCode(barcode);
          Get.find<BookQRAssignController>().submitQRCode();
        } else {
          final String barcode = Get.find<BarcodeController>().barcodeObs.value;
          if (barcode.isEmpty || barcode == '') {
            return;
          }
          Get.find<BookQRAssignController>().submitQRCode2(barcode);
        }
      },
      child: const Text('Submit'),
    );
  }
}
