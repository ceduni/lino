import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/form_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Lino_app/services/book_services.dart';
import 'dart:async';

import '../form_submission/confirm_book.dart';

class ISBNController extends GetxController {
  final TextEditingController textEditingController = TextEditingController();
  final BarcodeController barcodeController = Get.find<BarcodeController>();
  final BookService bookService = BookService();
  final FormController formController = Get.find<FormController>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isbnText = ''.obs;
  var bookTitle = ''.obs;
  var bookAuthor = ''.obs;
  var bookInfo = Rxn<Map<String, dynamic>>();

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    // Listen to changes in the barcode value
    ever(barcodeController.barcodeObs, (value) {
      if (value.isNotEmpty &&
          value != 'Unknown Barcode' &&
          value != 'No Barcode Detected') {
        textEditingController.text = value;
      }
    });

    // Listen to changes in the ISBN text
    textEditingController.addListener(() {
      isbnText.value = textEditingController.text;
      _fetchBookInfoDebounced();
    });
  }

  // Dispose the TextEditingController to avoid memory leaks
  @override
  void onClose() {
    textEditingController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _fetchBookInfoDebounced() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      _fetchBookInfo();
    });
  }

  // methode pour récupérer les infos du livre
  Future<void> _fetchBookInfo() async {
    final isbn = textEditingController.text.trim();
   
    bookTitle.value = '';
    bookInfo.value = null;
    errorMessage.value = '';
    
    // On fetch que si le ISBN est assez long
    if (isbn.length >= 10) {
      isLoading.value = true;
      try {
        final fetchedBookInfo = await bookService.getBookInfo(isbn);
        bookInfo.value = fetchedBookInfo;
        print('Fetched book info: $fetchedBookInfo');
        bookTitle.value = fetchedBookInfo['title'] ?? 'Unknown Title';
        bookAuthor.value = fetchedBookInfo['authors']?.join(', ') ?? 'Unknown Author';
      } catch (error) {
        // Pour clean
        bookTitle.value = '';
        bookInfo.value = null;
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Method to handle ISBN submission
  Future<void> submitISBN() async {
    final isbn = textEditingController.text;
    if (isbn.isEmpty) {
      errorMessage.value = 'ISBN cannot be empty';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      // Use already fetched book info if available, otherwise fetch it
      Map<String, dynamic> bookInfoToUse;
      if (bookInfo.value != null && bookTitle.value.isNotEmpty) {
        bookInfoToUse = bookInfo.value!;
      } else {
        bookInfoToUse = await bookService.getBookInfo(isbn);
      }
      
      formController.setSelectedISBN(isbn);
      Get.delete<BarcodeController>();
      Get.dialog(BookConfirmDialog(
          bookInfoFuture: Future.value(bookInfoToUse),
          bookBoxId: formController.selectedBookBox.value));
    } catch (error) {
      errorMessage.value = 'An error occurred: $error';
    } finally {
      isLoading.value = false;
    }
  }
}
