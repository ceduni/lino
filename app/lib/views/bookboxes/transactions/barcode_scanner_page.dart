import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:Lino_app/vm/bookboxes/transactions/barcode_scanner_view_model.dart';
import 'package:Lino_app/views/books/book_edition_page.dart';
import 'package:Lino_app/views/bookboxes/transactions/bookbox_book_list_page.dart';
import 'package:Lino_app/services/book_exchange_services.dart';
import 'package:Lino_app/utils/constants/colors.dart';

class BarcodeScannerPage extends StatefulWidget {
  final bool addingBook;
  final String bookboxId;
  
  const BarcodeScannerPage({
    super.key,
    required this.addingBook,
    required this.bookboxId,
  });

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  MobileScannerController? _controller;
  late BarcodeScannerViewModel _viewModel; // Local ViewModel instance

  @override
  void initState() {
    super.initState();
    // Create a new ViewModel instance for this page
    _viewModel = BarcodeScannerViewModel();
    _initializeController();
    
    // Start scanning when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.setParameters(widget.addingBook, widget.bookboxId);
      _viewModel.startScanning();
      // Listen for reset events
      _viewModel.addListener(_onViewModelChanged);
    });
  }

  void _initializeController() {
    // Dispose existing controller if any
    _controller?.dispose();
    _controller = null;
    
    // Create new controller with proper configuration
    _controller = MobileScannerController(
      autoStart: false,
    );
    
    // Add a small delay for iOS to properly release the camera before starting again
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && _controller != null) {
        _controller?.start();
      }
    });
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    
    if (_viewModel.shouldRestartCamera) {
      // Reinitialize the controller when resetScanner is called
      _initializeController();
      _viewModel.onCameraRestarted();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.fullReset(); // Full reset since this is a local instance
    _viewModel.dispose(); // Dispose the local ViewModel
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _showTakeBookConfirmation(EditableBook book) async {
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
                  child: Image.network(
                    book.coverImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildBookPlaceholder(book.title);
                    },
                  ),
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

  Future<void> _takeBook(EditableBook book) async {
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
        book.isbn,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan Book Barcode',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: LinoColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return SafeArea(
            child: Column(
              children: [
                // Top section - Book info card (when book is found) or Error card (when error occurs)
                if (_viewModel.scannedBook != null)
                  Flexible(
                    flex: 0,
                    child: _buildBookInfoCard(_viewModel.scannedBook!),
                  )
                else if (_viewModel.error != null)
                  Flexible(
                    flex: 0,
                    child: _buildErrorCard(_viewModel.error!),
                  )
                else
                  const SizedBox(height: 20), // Small space when no book
                
                // Middle section - Camera scanner (always visible)
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      // Camera scanner view
                      _buildScannerView(_viewModel),
                      // Rectangular barcode scanning overlay
                      _buildScanningOverlay(),
                    ],
                  ),
                ),
                
                // Bottom section - Fallback UI, Continue button, or Error actions
                if (_viewModel.showFallback || _viewModel.scannedBook != null || _viewModel.error != null)
                  Flexible(
                    flex: 0,
                    child: _viewModel.showFallback 
                        ? _buildFallbackUI()
                        : _viewModel.error != null
                            ? _buildErrorActions()
                            : _buildContinueButton(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScannerView(BarcodeScannerViewModel viewModel) {
    var didItVibrate = false;
    
    // Return black container if controller is null (during reinitialisation)
    if (_controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }
    
    return MobileScanner(
      controller: _controller!,
      onDetect: (BarcodeCapture capture) async {
        try {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
              try {
                if (await Vibration.hasVibrator()) {
                  if (!didItVibrate) {
                    Vibration.vibrate(duration: 250);
                    didItVibrate = true;
                  }
                }
              } catch (e) {
                // Ignore vibration errors
              }
              
              // Only process if we're still mounted and scanning
              if (mounted) {
                _viewModel.onBarcodeDetected(barcode.rawValue!);
              }
              break; // Process only the first barcode
            }
          }
        } catch (e) {
          // Handle any errors in barcode processing
          debugPrint('Error processing barcode: $e');
        }
      },
    );
  }

  Widget _buildScanningOverlay() {
    return Center(
      child: Container(
        width: 300,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Corner brackets for rectangular barcode scanner
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.green, width: 4),
                    left: BorderSide(color: Colors.green, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.green, width: 4),
                    right: BorderSide(color: Colors.green, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.green, width: 4),
                    left: BorderSide(color: Colors.green, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.green, width: 4),
                    right: BorderSide(color: Colors.green, width: 4),
                  ),
                ),
              ),
            ),
            // Center scanning line animation
            Center(
              child: Container(
                width: 250,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.green.withValues(alpha: 0.8),
                      Colors.green,
                      Colors.green.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookInfoCard(EditableBook book) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(250, 250, 240, 1),
                Color.fromRGBO(245, 245, 235, 1),
              ],
            ),
          ),
          child: Row(
            children: [
              // Book cover (smaller, on the left)
              Container(
                width: 80,
                height: 120,
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
                  child: Image.network(
                          book.coverImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildBookPlaceholder(book.title);
                          },
                        )
                ),
              ),
              const SizedBox(width: 16),
              // Book details (on the right)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kanit',
                        color: Color.fromRGBO(101, 67, 33, 1),
                      ),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackUI() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      "Can't find or scan the ISBN?",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kanit',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  /*
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<BarcodeScannerViewModel>().hideFallbackAndRestart();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  */
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.addingBook) {
                          // Navigate to manual entry form with empty EditableBook
                          Get.to(() => BookEditionPage(
                            bookboxId: widget.bookboxId,
                            editableBook: EditableBook(isbn: ''),
                          ));
                        } else {
                          // Navigate to book list for taking books
                          Get.to(() => BookboxBookListPage(
                            bookboxId: widget.bookboxId,
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(101, 67, 33, 1),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.addingBook ? 'Manual Entry' : 'Book List',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (widget.addingBook && _viewModel.scannedBook != null) {
                  // Navigate to book edition page with scanned book
                  Get.to(() => BookEditionPage(
                    bookboxId: widget.bookboxId,
                    editableBook: _viewModel.scannedBook!,
                  ));
                } else if (!widget.addingBook && _viewModel.scannedBook != null) {
                  // Show confirmation dialog for taking book
                  _showTakeBookConfirmation(_viewModel.scannedBook!);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _viewModel.resetScanner();
            },
            child: const Text(
              'Change book',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String errorMessage) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(255, 235, 235, 1),
                Color.fromRGBO(255, 220, 220, 1),
              ],
            ),
          ),
          child: Row(
            children: [
              // Error icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red.shade600,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              // Error message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Book Not Found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kanit',
                        color: Color.fromRGBO(180, 50, 50, 1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade700,
                        fontFamily: 'Kanit',
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _viewModel.resetScanner();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Try Another Book',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (!widget.addingBook)
            TextButton(
              onPressed: () {
                // Navigate to book list for taking books
                Get.to(() => BookboxBookListPage(
                  bookboxId: widget.bookboxId,
                ));
              },
              child: const Text(
                'View Available Books',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
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
}
