import 'package:Lino_app/pages/floating_button/dialog_options/book_qr_assign/book_qr_assign_dialog.dart';
import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/form_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Lino_app/services/book_services.dart';

class ISBNController extends GetxController {
  final TextEditingController textEditingController = TextEditingController();
  final BarcodeController barcodeController = Get.find<BarcodeController>();
  final BookService bookService = BookService();
  final FormController formController = Get.find<FormController>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to changes in the barcode value
    ever(barcodeController.barcodeObs, (value) {
      if (value.isNotEmpty &&
          value != 'Unknown Barcode' &&
          value != 'No Barcode Detected') {
        textEditingController.text = value;
        // isbnText.value = value; // Update the reactive variable
      }
    });
  }

  Future<void> submitISBN() async {
    final isbn = textEditingController.text;
    if (isbn.isEmpty) {
      errorMessage.value = 'ISBN cannot be empty';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      await bookService.getBookInfo(isbn); // to check if the ISBN is valid
      formController.setSelectedISBN(isbn);
      Get.delete<BarcodeController>();
      Get.dialog(BookQRAssignDialog());
      // Get.dialog(BookConfirmDialog(bookInfoFuture: Future.value(bookInfo)));
    } catch (error) {
      errorMessage.value = "An error occurred: $error";
    } finally {
      isLoading.value = false;
    }
  }

  void submitWithoutISBN() {
    formController.setSelectedISBN('');
    Get.delete<BarcodeController>();
    Get.dialog(BookQRAssignDialog());
  }
}
