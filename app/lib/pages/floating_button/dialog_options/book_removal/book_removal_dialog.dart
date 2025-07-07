import 'package:Lino_app/pages/floating_button/common/build_banner.dart';
import 'package:Lino_app/pages/floating_button/common/build_divider.dart';
import 'package:Lino_app/pages/floating_button/common/build_scanner.dart';
import 'package:Lino_app/pages/floating_button/common/barcode_controller.dart';
import 'package:Lino_app/pages/floating_button/dialog_options/book_removal/book_removal_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookRemovalDialog extends StatelessWidget {
  final String bookBoxId;
  final List<dynamic> books;

  const BookRemovalDialog({
    super.key,
    required this.bookBoxId,
    required this.books,
  });

  @override
  Widget build(BuildContext context) {
    final BarcodeController barcodeController = Get.put(BarcodeController());
    final BookRemovalController controller = Get.put(BookRemovalController());
    
    // Set the books in the controller
    controller.setBooks(books);

    return Dialog(
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildBanner(context, 'Remove Book'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    return controller.isISBNMode.value
                        ? _buildISBNScanMode(barcodeController, controller)
                        : _buildDropdownMode(controller);
                  }),
                  const SizedBox(height: 16.0),
                  _buildToggleModeButton(controller),
                  const SizedBox(height: 16.0),
                  _buildRemoveButton(controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildISBNScanMode(BarcodeController barcodeController, BookRemovalController controller) {
    return Column(
      children: [
        const Text('Scan the book\'s ISBN or enter it manually'),
        const SizedBox(height: 16.0),
        buildScanner(barcodeController),
        const SizedBox(height: 16.0),
        buildCustomDivider(),
        const SizedBox(height: 16.0),
        // ISBN input field
        TextFormField(
          controller: controller.isbnController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'ISBN',
            hintText: 'Enter ISBN manually or scan barcode',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            suffixIcon: Obx(() {
              return controller.currentISBN.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clearISBN();
                      },
                    )
                  : const SizedBox.shrink();
            }),
          ),
          onChanged: (value) {
            controller.onISBNChanged(value);
          },
        ),
        const SizedBox(height: 16.0),
        Obx(() {
          final currentISBN = controller.currentISBN.value;
          if (currentISBN.isNotEmpty) {
            final matchingBook = controller.findBookByISBN(currentISBN);
            if (matchingBook != null) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.green[100],
                ),
                child: Column(
                  children: [
                    Text('Book Found:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Title: ${matchingBook['title']}'),
                    Text('Authors: ${matchingBook['authors']?.join(', ') ?? 'Unknown'}'),
                  ],
                ),
              );
            } else {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.red[100],
                ),
                child: Text('No book found with ISBN: $currentISBN'),
              );
            }
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildDropdownMode(BookRemovalController controller) {
    return Column(
      children: [
        const Text('Tap on a book to select it for removal'),
        const SizedBox(height: 16.0),
        Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: _buildBookGrid(controller),
          ),
        ),
      ],
    );
  }

  Widget _buildBookGrid(BookRemovalController controller) {
    // Debug: Print the books to see what we're working with
    print('BookRemovalDialog: Received ${books.length} books');
    for (int i = 0; i < books.length; i++) {
      print('Book $i: ${books[i]}');
    }
    
    // Create a list of unique books with more lenient filtering
    final uniqueBooks = <String, Map<String, dynamic>>{};
    for (int i = 0; i < books.length; i++) {
      final book = books[i];
      // Use index as fallback ID if book doesn't have a proper ID
      final bookId = book['id']?.toString() ?? book['_id']?.toString() ?? 'book_$i';
      
      if (bookId.isNotEmpty) {
        uniqueBooks[bookId] = book;
      }
    }
    
    print('BookRemovalDialog: Filtered to ${uniqueBooks.length} unique books');
    
    if (uniqueBooks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Text(
              'No books available in this bookbox',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Debug: Received ${books.length} books but none had valid IDs',
              style: TextStyle(fontSize: 12, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return Obx(() {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: uniqueBooks.entries.map((entry) {
          final bookId = entry.key;
          final book = entry.value;
          final isSelected = controller.selectedBookId.value == bookId;
          
          return _buildSelectableBookItem(book, bookId, isSelected, controller);
        }).toList(),
      );
    });
  }

  Widget _buildSelectableBookItem(
    Map<String, dynamic> book, 
    String bookId, 
    bool isSelected, 
    BookRemovalController controller
  ) {
    String title = book['title'] ?? 'Unknown Title';
    List<dynamic> authors = book['authors'] ?? [];
    String authorsString = authors.isNotEmpty ? authors.join(', ') : 'Unknown Author';

    return GestureDetector(
      onTap: () => controller.setSelectedBook(bookId),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2.0),
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.transparent,
            width: 3.0,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          children: [
            _buildSelectableBookCover(book, isSelected),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.red : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authorsString,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.red[700] : Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    Icon(
                      Icons.check_circle,
                      color: Colors.red,
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableBookCover(Map<String, dynamic> book, bool isSelected) {
    String? coverImage = book['coverImage'];
    String title = book['title'] ?? 'Unknown Title';
    
    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
        border: isSelected ? Border.all(color: Colors.red, width: 2) : null,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
        child: coverImage != null && coverImage.isNotEmpty
            ? Image.network(
                coverImage,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return Container(
                    width: 120,
                    height: 160,
                    color: isSelected ? Colors.red[100] : Colors.grey,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isSelected ? Colors.red[800] : Colors.white,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container(
                width: 120,
                height: 160,
                color: isSelected ? Colors.red[100] : Colors.grey,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.red[800] : Colors.white,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildToggleModeButton(BookRemovalController controller) {
    return ElevatedButton(
      onPressed: controller.toggleMode,
      child: Obx(() {
        return Text(controller.isISBNMode.value
            ? 'Select visually instead'
            : 'Scan ISBN instead');
      }),
    );
  }

  Widget _buildRemoveButton(BookRemovalController controller) {
    return Obx(() {
      return ElevatedButton(
        onPressed: controller.canRemove
            ? () => controller.removeBook(bookBoxId)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.canRemove ? Colors.red : Colors.grey,
          foregroundColor: Colors.white,
        ),
        child: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Remove Book'),
      );
    });
  }
}
