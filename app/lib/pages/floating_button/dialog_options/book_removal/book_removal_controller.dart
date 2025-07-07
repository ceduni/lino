import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:Lino_app/services/bookbox_state_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookRemovalController extends GetxController {
  final isISBNMode = true.obs;
  final selectedBookId = ''.obs;
  final isLoading = false.obs;
  final books = <dynamic>[].obs;
  final currentISBN = ''.obs;
  
  late BarcodeController barcodeController;
  late TextEditingController isbnController;

  @override
  void onInit() {
    super.onInit();
    barcodeController = Get.find<BarcodeController>();
    isbnController = TextEditingController();
    
    // Listen to barcode changes when in ISBN mode
    ever(barcodeController.barcodeObs, (String value) {
      if (isISBNMode.value && value.isNotEmpty && 
          value != 'Unknown Barcode' && value != 'No Barcode Detected') {
        // Auto-fill the ISBN input field
        isbnController.text = value;
        currentISBN.value = value;
        
        final matchingBook = findBookByISBN(value);
        if (matchingBook != null) {
          selectedBookId.value = matchingBook['id']?.toString() ?? matchingBook['_id']?.toString() ?? '';
        } else {
          selectedBookId.value = '';
        }
      }
    });
  }

  void setBooks(List<dynamic> bookList) {
    books.value = bookList;
    
    // Check if the currently selected book still exists in the new list
    if (selectedBookId.value.isNotEmpty) {
      final bookExists = bookList.any((book) => book['id']?.toString() == selectedBookId.value);
      if (!bookExists) {
        selectedBookId.value = ''; // Clear selection if book no longer exists
      }
    }
  }

  void toggleMode() {
    isISBNMode.value = !isISBNMode.value;
    selectedBookId.value = ''; // Reset selection when switching modes
    barcodeController.barcodeObs.value = ''; // Clear barcode when switching modes
    clearISBN(); // Clear ISBN input when switching modes
  }

  void setSelectedBook(String bookId) {
    selectedBookId.value = bookId;
  }

  void onISBNChanged(String value) {
    currentISBN.value = value;
    
    // Update selection based on ISBN
    final matchingBook = findBookByISBN(value);
    if (matchingBook != null) {
      selectedBookId.value = matchingBook['id']?.toString() ?? matchingBook['_id']?.toString() ?? '';
    } else {
      selectedBookId.value = '';
    }
  }

  void clearISBN() {
    isbnController.clear();
    currentISBN.value = '';
    selectedBookId.value = '';
  }

  Map<String, dynamic>? findBookByISBN(String isbn) {
    try {
      return books.firstWhere(
        (book) => book['isbn'] == isbn,
        orElse: () => null,
      );
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? findBookById(String bookId) {
    try {
      // Handle fallback IDs
      if (bookId.startsWith('book_')) {
        final index = int.tryParse(bookId.substring(5));
        if (index != null && index < books.length) {
          return books[index];
        }
      }
      
      return books.firstWhere(
        (book) => book['id']?.toString() == bookId || book['_id']?.toString() == bookId,
        orElse: () => null,
      );
    } catch (e) {
      return null;
    }
  }

  bool get canRemove {
    if (isISBNMode.value) {
      return currentISBN.value.isNotEmpty && findBookByISBN(currentISBN.value) != null;
    } else {
      return selectedBookId.value.isNotEmpty;
    }
  }

  Future<void> removeBook(String bookBoxId) async {
    if (!canRemove || isLoading.value) return;

    isLoading.value = true;

    try {
      var prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');

      String bookIdToRemove;
      
      if (isISBNMode.value) {
        final matchingBook = findBookByISBN(currentISBN.value);
        if (matchingBook == null) {
          throw Exception('Book not found');
        }
        bookIdToRemove = matchingBook['id']?.toString() ?? matchingBook['_id']?.toString() ?? '';
      } else {
        final selectedBook = findBookById(selectedBookId.value);
        if (selectedBook == null) {
          throw Exception('Selected book not found');
        }
        bookIdToRemove = selectedBook['id']?.toString() ?? selectedBook['_id']?.toString() ?? '';
      }

      if (bookIdToRemove.isEmpty) {
        throw Exception('Book ID not found');
      }

      await BookService().getBookFromBB(bookIdToRemove, bookBoxId, token: token);

      // Trigger refresh for all bookbox displays
      BookBoxStateService.instance.triggerRefresh();

      // Show success message
      showToast('Book has been successfully removed from the Book Box.');
      
      // Close all dialogs and return to main screen
      Get.back(); // Close current dialog
      Get.back(); // Close bookbox selection dialog
      
    } catch (e) {
      print('Error removing book: $e');
      Get.snackbar('Error', 'Failed to remove book: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
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
  void onClose() {
    // Clean up
    isbnController.dispose();
    super.onClose();
  }
}
