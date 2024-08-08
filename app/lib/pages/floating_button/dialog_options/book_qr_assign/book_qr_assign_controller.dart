import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/form_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/book_services.dart';
import '../../../../utils/constants/colors.dart';

class BookQRAssignController extends GetxController {
  // Observable for the selected QR Code
  var selectedQRCode = ''.obs;

  // Reference to BarcodeController and FormController
  final BarcodeController barcodeController = Get.find<BarcodeController>();
  final FormController formController = Get.find<FormController>();

  // Submit the QR Code by setting it in the FormController
  Future<void> submitQRCode() async {
    formController.setSelectedQRCode(barcodeController.barcodeObs.value);

    // Delete the BarcodeController after using it
    Get.delete<BarcodeController>();

    // Check if ISBN is available and submit the form accordingly
    if (formController.selectedISBN.value.isEmpty) {
      formController.submitFormWithoutISBN();
    } else {
      formController.submitFormWithISBN();
    }
  }

  Future<void> submitQRCode2(String qrCodeVal) async {
    // Fetch the book details
    final book = await BookService().getBook(qrCodeVal);
    final title = book['title'];

    // Observable to track loading state
    var isLoading = false.obs;

    // Show the dialog
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
                () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Confirm that you\'re taking the book:',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  '"$title"',
                  style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Dismiss the dialog
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LinoColors.primary,
                      ),
                      child: const Text('Cancel'),
                    ),
                    isLoading.value
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () async {
                        // Set loading to true
                        isLoading.value = true;
                        var prefs = await SharedPreferences.getInstance();
                        final token = prefs.getString('token');
                        // Perform confirm action
                        await BookService().getBookFromBB(
                            qrCodeVal, formController.selectedBookBox.value, token: token);
                        showToast('Book successfully taken');
                        // Set loading to false
                        isLoading.value = false;
                        // Dismiss the dialog
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LinoColors.secondary,
                      ),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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

  @override
  void onInit() {
    super.onInit();
    // React to changes in the barcode value
    ever(barcodeController.barcodeObs, (value) {
      if (value.isNotEmpty &&
          value != 'Unknown Barcode' &&
          value != 'No Barcode Detected') {
        selectedQRCode.value = value;
      }
    });
  }
}
