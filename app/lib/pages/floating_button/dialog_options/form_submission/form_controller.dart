import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/confirm_book.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormController extends GetxController {
  // Observables for form fields
  var selectedBookBox = ''.obs;
  var selectedQRCode = ''.obs;
  var selectedISBN = ''.obs;

  // Observable for dialog state
  var isISBNDialogExpanded = false.obs;
  var additionalFieldsForISBN = <String, TextEditingController>{}.obs;

  // Getter to check if additional fields are empty
  bool get isAdditionalFieldsEmpty =>
      additionalFieldsForISBN.values.every((element) => element.text.isEmpty);

  @override
  void onInit() {
    super.onInit();
    // Initialize additional fields
    additionalFieldsForISBN['Title'] = TextEditingController();
    additionalFieldsForISBN['Author'] = TextEditingController();
    additionalFieldsForISBN['Year'] = TextEditingController();
  }

  // Toggle expand/collapse of ISBN dialog
  void toggleExpand() {
    isISBNDialogExpanded.value = !isISBNDialogExpanded.value;
  }

  // Setters for form fields
  void setSelectedBookBox(String value) {
    selectedBookBox.value = value;
  }

  void setSelectedQRCode(String value) {
    selectedQRCode.value = value;
  }

  void setSelectedISBN(String value) {
    selectedISBN.value = value;
  }

  // Submit form with ISBN
  Future<void> submitFormWithISBN() async {
    try {
      final bookInfo = await BookService().getBookInfo(selectedISBN.value);
      Get.dialog(BookConfirmDialog(
          bookInfoFuture: Future.value(bookInfo),
          bookBoxId: selectedBookBox.value,
          bookQrCode: selectedQRCode.value));
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch book info: $e');
    }
  }

  // Submit form without ISBN
  void submitFormWithoutISBN() {
    final bookInfo = {
      'title': additionalFieldsForISBN['Title']!.text,
      'authors': [additionalFieldsForISBN['Author']!.text],
      'parutionYear': int.tryParse(additionalFieldsForISBN['Year']!.text) ?? 0,
    };

    Get.dialog(BookConfirmDialog(
        bookInfoFuture: Future.value(bookInfo),
        bookBoxId: selectedBookBox.value,
        bookQrCode: selectedQRCode.value));
  }

  @override
  void onClose() {
    // Dispose controllers to avoid memory leaks
    additionalFieldsForISBN.values
        .forEach((controller) => controller.dispose());
    super.onClose();
  }
}
