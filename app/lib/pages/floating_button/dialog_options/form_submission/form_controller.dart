import 'dart:io';
import 'package:Lino_app/pages/floating_button/dialog_options/form_submission/confirm_book.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:Lino_app/services/image_upload_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class FormController extends GetxController {
  // Observables for form fields
  var selectedBookBox = ''.obs;
  var selectedISBN = ''.obs;
 
  // Observable for dialog state
  var isISBNDialogExpanded = false.obs;
  var additionalFieldsForISBN = <String, TextEditingController>{}.obs;

  // Image handling
  var selectedCoverImage = Rxn<File>();
  var isUploadingImage = false.obs;
  final ImageUploadService _imageUploadService = ImageUploadService();

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
    additionalFieldsForISBN['Pages'] = TextEditingController();
    additionalFieldsForISBN['Description'] = TextEditingController();
    additionalFieldsForISBN['Publisher'] = TextEditingController();
    additionalFieldsForISBN['Categories'] = TextEditingController();
  }

  // Toggle expand/collapse of ISBN dialog
  void toggleExpand() {
    isISBNDialogExpanded.value = !isISBNDialogExpanded.value;
  }

  // Setters for form fields
  void setSelectedBookBox(String value) {
    selectedBookBox.value = value;
  }

  void setSelectedISBN(String value) {
    selectedISBN.value = value;
  }

  // Image handling methods
  void onImageSelected(File? imageFile) {
    selectedCoverImage.value = imageFile;
  }

  Future<String?> _uploadCoverImage() async {
    if (selectedCoverImage.value == null) return null;
    
    try {
      isUploadingImage.value = true;
      showToast('Uploading cover image...');
      
      final imageUrl = await _imageUploadService.uploadImage(selectedCoverImage.value!);
      
      if (imageUrl != null) {
        showToast('Cover image uploaded successfully!');
        return imageUrl;
      } else {
        showToast('Failed to upload cover image');
        return null;
      }
    } catch (e) {
      print('Error uploading cover image: $e');
      showToast('Error uploading cover image: $e');
      return null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  // Submit form with ISBN
  Future<void> submitFormWithISBN() async {
    try {
      final bookInfo = await BookService().getBookInfo(selectedISBN.value);
      Get.dialog(BookConfirmDialog(
          bookInfoFuture: Future.value(bookInfo),
          bookBoxId: selectedBookBox.value));
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch book info: $e');
    }
  }

  // Submit form without ISBN
  Future<void> submitFormWithoutISBN() async {
    // Check if the title field is empty
    if (additionalFieldsForISBN['Title']!.text.isEmpty) {
      showToast('Title field cannot be empty');
      return;
    }

    // Upload cover image if selected
    String? coverImageUrl;
    if (selectedCoverImage.value != null) {
      coverImageUrl = await _uploadCoverImage();
      // If upload failed and user had selected an image, ask if they want to continue
      if (coverImageUrl == null) {
        final shouldContinue = await Get.dialog<bool>(
          AlertDialog(
            title: Text('Image Upload Failed'),
            content: Text('The cover image could not be uploaded. Do you want to continue without the image?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Get.back(result: false),
              ),
              TextButton(
                child: Text('Continue'),
                onPressed: () => Get.back(result: true),
              ),
            ],
          ),
        );
        
        if (shouldContinue != true) {
          return; // User chose to cancel
        }
      }
    }

    // Parse categories from comma-separated string
    final categoriesText = additionalFieldsForISBN['Categories']!.text.trim();
    final categories = categoriesText.isNotEmpty 
        ? categoriesText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    // Parse authors from comma-separated string
    final authorsText = additionalFieldsForISBN['Author']!.text.trim();
    final authors = authorsText.isNotEmpty 
        ? authorsText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    final bookInfo = {
      'title': additionalFieldsForISBN['Title']!.text.trim(),
      'authors': authors,
      'description': additionalFieldsForISBN['Description']!.text.trim().isNotEmpty 
          ? additionalFieldsForISBN['Description']!.text.trim() 
          : null,
      'publisher': additionalFieldsForISBN['Publisher']!.text.trim().isNotEmpty 
          ? additionalFieldsForISBN['Publisher']!.text.trim() 
          : null,
      'parutionYear': int.tryParse(additionalFieldsForISBN['Year']!.text.trim()),
      'pages': int.tryParse(additionalFieldsForISBN['Pages']!.text.trim()),
      'categories': categories.isNotEmpty ? categories : null,
      'isbn': null, // No ISBN for manual entry
      'coverImage': coverImageUrl, // Use uploaded image URL
    };

    Get.dialog(BookConfirmDialog(
        bookInfoFuture: Future.value(bookInfo),
        bookBoxId: selectedBookBox.value));
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
    // Dispose controllers to avoid memory leaks
    for (final controller in additionalFieldsForISBN.values) {
      controller.dispose();
    }
    super.onClose();
  }
}
