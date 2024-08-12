import 'package:Lino_app/pages/floating_button/common/build_scanner.dart';
import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/book_qr_assign/book_qr_assign_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/form_controller.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:Lino_app/pages/floating_button/common/build_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookQRAssignDialog extends StatelessWidget {
  final bool isAddBook;
  final Map<String, dynamic> formInfo;
  final bool isNewBook;

  const BookQRAssignDialog({
    super.key,
    required this.isAddBook,
    required this.formInfo,
    required this.isNewBook,
  });

  @override
  Widget build(BuildContext context) {
    final BarcodeController barcodeController = Get.put(BarcodeController());
    Get.lazyPut(() => FormController());
    Get.lazyPut(() => BookQRAssignController());
    final isLoading = false.obs; // Observable to track loading status

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
                  isAddBook
                      ? isNewBook
                          ? const Text('Take a QR code sticker, stick it on the book and scan it')
                          : const Text("Scan the book's existing QR code")
                      : const Text("Scan the chosen book's existing QR code"),
                  const SizedBox(height: 16.0),
                  buildScanner(barcodeController),
                  const SizedBox(height: 16.0),
                  Obx(() {
                    return isLoading.value
                        ? const CircularProgressIndicator()
                        : _buildSubmitButton(isLoading);
                  }),
                  const SizedBox(height: 16.0),
                  Obx(() => Text(Get.find<BarcodeController>().barcodeObs.value)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(RxBool isLoading) {
    return ElevatedButton(
      onPressed: () async {
        final String barcode = Get.find<BarcodeController>().barcodeObs.value;
        if (barcode.isEmpty || barcode == '') {
          return;
        }

        isLoading.value = true; // Show loading indicator

        try {
          if (isAddBook) {
            if (isNewBook) {
              await BookService().addBookToBB(
                barcode,
                formInfo['bookBoxId'],
                token: formInfo['token'],
                isbn: formInfo['isbn'],
                title: formInfo['title'],
                authors: formInfo['authors'],
                description: formInfo['description'],
                coverImage: formInfo['coverImage'],
                publisher: formInfo['publisher'],
                parutionYear: formInfo['parutionYear'],
                pages: formInfo['pages'],
                categories: formInfo['categories'],
              );

              // Show success confirmation
              showToast('Book has been successfully added to the Book Box.');
              isLoading.value = false; // Hide loading indicator

              // Close the dialog
              Get.back();
            } else {
              var prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('token');
              await BookService().addBookToBB(
                barcode,
                formInfo['bookBoxId'],
                token: token,
              );
              // Show success confirmation
              showToast('Book has been successfully added to the Book Box.');
              isLoading.value = false; // Hide loading indicator

              // Close the dialog
              Get.back();
            }

          } else {
            Get.find<BookQRAssignController>().submitQRCode2(barcode);
            // Ensure the dialog is closed after submitting the QR code
            Get.back();
          }

        } catch (e) {
          // Handle any error that occurs during the process
          Get.snackbar('Error', 'Failed to submit: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          print('Error: $e');
        }
      },
      child: Obx(() => isLoading.value
          ? CircularProgressIndicator(color: Colors.white)
          : Text('Submit')
      ),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}


