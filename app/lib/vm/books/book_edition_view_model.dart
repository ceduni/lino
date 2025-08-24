import 'package:flutter/material.dart';
import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/services/book_exchange_services.dart';
import 'package:Lino_app/services/image_upload_service.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class BookEditionViewModel extends ChangeNotifier {
  late EditableBook _editableBook;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  final BookExchangeService _bookExchangeService = BookExchangeService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  // Getters
  EditableBook get editableBook => _editableBook;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isUploadingImage => _isUploadingImage;

  void initializeBook(EditableBook book) {
    _editableBook = EditableBook(
      isbn: book.isbn,
      title: book.title,
      authors: List<String>.from(book.authors),
      description: book.description,
      coverImage: book.coverImage,
      publisher: book.publisher,
      parutionYear: book.parutionYear,
      pages: book.pages,
      categories: List<String>.from(book.categories),
    );
    _isInitialized = true;
    notifyListeners();
  }

  void updateTitle(String title) {
    _editableBook.title = title.trim().isEmpty ? 'Unknown Title' : title.trim();
    notifyListeners();
  }

  void updateAuthors(String authorsString) {
    if (authorsString.trim().isEmpty) {
      _editableBook.authors = ['Unknown Author'];
    } else {
      _editableBook.authors = authorsString
          .split(',')
          .map((author) => author.trim())
          .where((author) => author.isNotEmpty)
          .toList();
      
      if (_editableBook.authors.isEmpty) {
        _editableBook.authors = ['Unknown Author'];
      }
    }
    notifyListeners();
  }

  void updateDescription(String description) {
    _editableBook.description = description.trim().isEmpty ? 'No description available' : description.trim();
    notifyListeners();
  }

  void updatePublisher(String publisher) {
    _editableBook.publisher = publisher.trim().isEmpty ? 'Unknown publisher' : publisher.trim();
    notifyListeners();
  }

  void updateParutionYear(String yearString) {
    if (yearString.trim().isEmpty) {
      _editableBook.parutionYear = null;
    } else {
      final year = int.tryParse(yearString.trim());
      if (year != null && year > 0 && year <= DateTime.now().year + 10) {
        _editableBook.parutionYear = year;
      } else {
        _editableBook.parutionYear = null;
      }
    }
    notifyListeners();
  }

  void updatePages(String pagesString) {
    if (pagesString.trim().isEmpty) {
      _editableBook.pages = null;
    } else {
      final pages = int.tryParse(pagesString.trim());
      if (pages != null && pages > 0) {
        _editableBook.pages = pages;
      } else {
        _editableBook.pages = null;
      }
    }
    notifyListeners();
  }

  void updateCategories(String categoriesString) {
    if (categoriesString.trim().isEmpty) {
      _editableBook.categories = ['Uncategorized'];
    } else {
      _editableBook.categories = categoriesString
          .split(',')
          .map((category) => category.trim())
          .where((category) => category.isNotEmpty)
          .toList();
      
      if (_editableBook.categories.isEmpty) {
        _editableBook.categories = ['Uncategorized'];
      }
    }
    notifyListeners();
  }

  Future<void> updateCoverImageFromFile(File imageFile) async {
    _isUploadingImage = true;
    notifyListeners();

    try {
      final imageUrl = await _imageUploadService.uploadImage(imageFile);
      if (imageUrl != null) {
        _editableBook.coverImage = imageUrl;
      }
    } catch (e) {
      print('Error uploading image: $e');
      // Keep the existing cover image if upload fails
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  void updateCoverImage(String imageUrl) {
    _editableBook.coverImage = imageUrl;
    notifyListeners();
  }

  Future<void> addBookToBookBox(String bookboxId) async {
    _isLoading = true;
    notifyListeners();

    // Get user token from secure storage
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');


    try {
      await _bookExchangeService.addBookToBB(bookboxId, _editableBook, token: token);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
