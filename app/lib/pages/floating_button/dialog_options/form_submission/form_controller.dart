import 'package:Lino_app/pages/floating_button/dialog_options/confirm_book.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormController extends GetxController {
  var selectedBookbox = ''.obs;
  var selectedQRCode = ''.obs;
  var selectedISBN = ''.obs;

  var isISBNDialogExpanded = false.obs;
  var additionalFieldsForISBN = <String, TextEditingController>{}.obs;

  bool get isAdditionalFieldsEmpty =>
      additionalFieldsForISBN.values.every((element) => element.text.isEmpty);

  void toggleExpand() {
    isISBNDialogExpanded.value = !isISBNDialogExpanded.value;
    if (isISBNDialogExpanded.value && additionalFieldsForISBN.isEmpty) {
      additionalFieldsForISBN['Title'] = TextEditingController();
      additionalFieldsForISBN['Author'] = TextEditingController();
      additionalFieldsForISBN['Year'] = TextEditingController();
    }
  }

  void setSelectedBookBox(String value) {
    selectedBookbox.value = value;
  }

  void setSelectedQRCode(String value) {
    selectedQRCode.value = value;
  }

  void setSelectedISBN(String value) {
    selectedISBN.value = value;
  }

  Future<void> submitFormWithISBN() async {
    final bookInfo = await BookService().getBookInfo(selectedISBN.value);
    Get.dialog(BookConfirmDialog(
        bookInfoFuture: Future.value(bookInfo),
        bookBoxId: selectedBookbox.value,
        bookQrCode: selectedQRCode.value));
  }

  void submitFormWithoutISBN() {
    final bookInfo = {
      'title': additionalFieldsForISBN['Title']!.text,
      'authors': [additionalFieldsForISBN['Author']!.text],
      'parutionYear': additionalFieldsForISBN['Year']!.text,
    };

    Get.dialog(BookConfirmDialog(
        bookInfoFuture: Future.value(bookInfo),
        bookBoxId: selectedBookbox.value,
        bookQrCode: selectedQRCode.value));
  }
}
