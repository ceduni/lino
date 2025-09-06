import 'package:Lino_app/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/services/bookbox_services.dart';
import 'package:Lino_app/services/book_exchange_services.dart';

class BookboxBookListPage extends StatefulWidget {
  final String bookboxId;
  
  const BookboxBookListPage({
    super.key,
    required this.bookboxId,
  });

  @override
  State<BookboxBookListPage> createState() => _BookboxBookListPageState();
}

class _BookboxBookListPageState extends State<BookboxBookListPage> {
  BookBox? bookbox;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadBookbox();
  }

  Future<void> _loadBookbox() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      final loadedBookbox = await BookboxService().getBookBox(widget.bookboxId);
      
      setState(() {
        bookbox = loadedBookbox;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _confirmTakeBook(Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirm Book Selection',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(101, 67, 33, 1),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Book cover
              Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: book.coverImage != null
                      ? Image.network(
                          book.coverImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildBookPlaceholder(book.title);
                          },
                        )
                      : _buildBookPlaceholder(book.title),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                book.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Kanit',
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                book.authors.isNotEmpty ? book.authors.join(', ') : 'Unknown Author',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Kanit',
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to take this book?',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Kanit',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Take Book',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _takeBook(book);
    }
  }

  Future<void> _takeBook(Book book) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text(
                  'Taking book...',
                  style: TextStyle(fontFamily: 'Kanit'),
                ),
              ],
            ),
          );
        },
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      await BookExchangeService().getBookFromBB(
        widget.bookboxId,
        book.isbn ?? '',
        token: token,
      );

      // Close loading dialog
      Get.back();

      // Navigate back to previous screen
      Get.back();
      Get.back(); // Go back twice to return to the main screen

      // Show success message
      CustomSnackbars.success(
        'Success',
        'Successfully took "${book.title}"',
      );
    } catch (e) {
      // Close loading dialog
      Get.back();

      // Show error message
      CustomSnackbars.error(
        'Error',
        'Failed to take book: ${e.toString()}',
      );
    }
  }

  Widget _buildBookPlaceholder(String title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[400]!, Colors.grey[600]!],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit',
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Available Books',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(101, 67, 33, 1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading books',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kanit',
                            color: Colors.red[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Kanit',
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadBookbox,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(101, 67, 33, 1),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Kanit',
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : bookbox == null || bookbox!.books.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No books available',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Kanit',
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'This bookbox is currently empty.',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Kanit',
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: bookbox!.books.length,
                        itemBuilder: (context, index) {
                          final book = bookbox!.books[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () => _confirmTakeBook(book),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Book cover
                                    Container(
                                      width: 60,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: book.coverImage != null
                                            ? Image.network(
                                                book.coverImage!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return _buildBookPlaceholder(book.title);
                                                },
                                              )
                                            : _buildBookPlaceholder(book.title),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Book details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            book.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Kanit',
                                              color: Color.fromRGBO(101, 67, 33, 1),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            book.authors.isNotEmpty 
                                                ? book.authors.join(', ') 
                                                : 'Unknown Author',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                              fontFamily: 'Kanit',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (book.categories.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              book.categories.join(', '),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                                fontFamily: 'Kanit',
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // Arrow icon
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey[400],
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
