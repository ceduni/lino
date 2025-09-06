// app/lib/pages/bookbox/book_box_page.dart
import 'dart:io';
import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/views/bookboxes/book_box_issue_report_page.dart';
import 'package:Lino_app/views/bookboxes/transactions/barcode_scanner_page.dart';
import 'package:Lino_app/views/books/book_details_page.dart';
import 'package:Lino_app/vm/bookboxes/book_box_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:Lino_app/vm/search/search_page_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:Lino_app/utils/constants/colors.dart';


class BookBoxPage extends StatefulWidget {
  const BookBoxPage({super.key});

  @override
  State<BookBoxPage> createState() => _BookBoxPageState();
}

class _BookBoxPageState extends State<BookBoxPage> {
  String? bookBoxId;
  bool canInteract = false;

  @override
  void initState() {
    super.initState();

    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      bookBoxId = arguments['bookboxId'] as String?;
      canInteract = arguments['canInteract'] as bool? ?? false;
    }

    if (bookBoxId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final viewModel = context.read<BookBoxViewModel>();
        viewModel.loadBookBoxData(bookBoxId!);
        viewModel.checkAuthAndFollowStatus(bookBoxId!);
      });
    }
  }

  String _getTimeAgo(DateTime dateAdded) {
    return timeago.format(dateAdded, locale: 'en');
  }


  void _showInfoDialog(BookBox bookBox) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: LinoColors.accent,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bookBox.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kanit',
                          color: LinoColors.accent,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bookBox.infoText!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Kanit',
                      color: LinoColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _openGoogleMapsApp(bookBox.latitude, bookBox.longitude);
                    },
                    icon: const Icon(Icons.directions, color: Colors.white),
                    label: const Text(
                      'Get Directions',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LinoColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (bookBoxId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: const Center(
          child: Text(
            'No bookbox ID provided',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Consumer<BookBoxViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: LinoColors.lightContainer,
          appBar: AppBar(
            title: Text(
              viewModel.bookBox?.name ?? 'BookBox',
              style: TextStyle(
                fontFamily: 'Kanit',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: LinoColors.accent,
            foregroundColor: Colors.white,
            elevation: 2,
            /*actions: [
              IconButton(
                onPressed: () async {
                  final result = await Get.to(() => BookBoxIssueReportPage(bookboxId: bookBoxId!));
                  if (result != null && result['success'] == true) {
                    Get.snackbar(
                      'Success',
                      result['message'] ?? 'Issue reported successfully',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                },
                icon: const Icon(Icons.report, color: Colors.white),
                tooltip: 'Report Issue',
              ),
              
            ], */
          ),
          body: SafeArea(
            child: _buildBody(viewModel),
          ),
        );
      },
    );
  }

  Widget _buildBody(BookBoxViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LinoColors.lightContainer),
        ),
      );
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error loading bookbox data',
              style: TextStyle(fontSize: 18, fontFamily: 'Kanit', color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.error!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (viewModel.bookBox == null) {
      return const Center(
        child: Text(
          'No bookbox data available',
          style: TextStyle(fontSize: 18, fontFamily: 'Kanit', color: Colors.grey),
        ),
      );
    }

    return _buildContent(viewModel.bookBox!);
  }

  Widget _buildMapSection(BookBox bookBox) {
    return GoogleMap(initialCameraPosition: CameraPosition(
      target: LatLng(bookBox.latitude, bookBox.longitude),
      zoom: 15,
    ),
    markers: {
      Marker(
        markerId: MarkerId(bookBox.id),
        position: LatLng(bookBox.latitude, bookBox.longitude),
        infoWindow: InfoWindow(title: bookBox.name),
      ),
    },);
  }

  Widget _buildContent(BookBox bookBox) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!bookBox.isActive) _buildMaintenanceBanner(),
          _buildBookBoxInfoCard(bookBox, context.read<BookBoxViewModel>()),
          if (canInteract) const SizedBox(height: 20),
          _buildActionButtons(bookBox),
          if (!canInteract) ...[
            const SizedBox(height: 20),
            _buildBooksSection(bookBox),
          ],
          const SizedBox(height: 20),
          if (!canInteract)
          TextButton(
            onPressed: () {
              final searchViewModel = context.read<SearchPageViewModel>();
              searchViewModel.createRequest("");
            },
            
            child: const Center(child: Text("Didn't find your book? Create a new request !", style: TextStyle(
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w600,
              color: LinoColors.accent,
            ),)),

          ),
          Center(
            child: TextButton.icon(
              onPressed: () async {
                  final result = await Get.to(() => BookBoxIssueReportPage(bookboxId: bookBoxId!));
                  if (result != null && result['success'] == true) {
                    Get.snackbar(
                      'Success',
                      result['message'] ?? 'Issue reported successfully',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                },
              icon: const Icon(Icons.flag),
              label: const Text("Report issue with this BookBox"),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                textStyle: const TextStyle(
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  // Keep all the existing UI building methods unchanged
  Widget _buildMaintenanceBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        border: Border.all(color: Colors.orange.shade400, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.construction, color: Colors.orange.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Under Maintenance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kanit',
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This BookBox is temporarily deactivated for maintenance. You can view the books inside but cannot exchange books from it until it\'s reactivated.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Kanit',
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookBoxInfoCard(BookBox bookBox, BookBoxViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              LinoColors.lightContainer,
              LinoColors.lightContainer,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bookBox.image != null && bookBox.image!.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          bookBox.image!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                      // Heart button for follow/unfollow
                      if (viewModel.token != null)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: viewModel.isCheckingFollowStatus
                                ? const Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: SizedBox(
                                      width: 26,
                                      height: 26,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(101, 67, 33, 1)),
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    onPressed: () async {
                                      final success = await viewModel.toggleFollow(bookBoxId!);
                                      if (success) {
                                        Get.snackbar(
                                          viewModel.isFollowed ? 'Following' : 'Unfollowed',
                                          viewModel.isFollowed
                                              ? 'You are now following this BookBox'
                                              : 'You have unfollowed this BookBox',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: viewModel.isFollowed ? Colors.green : Colors.orange,
                                          colorText: Colors.white,
                                        );
                                      } else {
                                        Get.snackbar(
                                          'Error',
                                          'Failed to ${viewModel.isFollowed ? 'unfollow' : 'follow'} BookBox',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      viewModel.isFollowed ? Icons.favorite : Icons.favorite_border,
                                      color: viewModel.isFollowed ? Colors.red : Colors.grey.shade600,
                                      size: 26,
                                    ),
                                    tooltip: viewModel.isFollowed ? 'Unfollow BookBox' : 'Follow BookBox',
                                    padding: const EdgeInsets.all(2),
                                    constraints: const BoxConstraints(
                                      minWidth: 26,
                                      minHeight: 26,
                                    ),
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  Expanded(
                    child: Center(
                      child: Text(
                        bookBox.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Kanit',
                          color: LinoColors.buttonPrimary,
                        ),
                      ),
                    ),
                  ),
                  
                  /*
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!canInteract)
                        IconButton(
                          onPressed: () => _openGoogleMapsApp(bookBox.latitude, bookBox.longitude),
                          icon: const Icon(
                            Icons.directions,
                            color: Color.fromRGBO(101, 67, 33, 1),
                          ),
                          tooltip: 'Get Directions',
                        ),
                      if (viewModel.token != null)
                        viewModel.isCheckingFollowStatus
                            ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(101, 67, 33, 1)),
                            ),
                          ),
                        )
                            : IconButton(
                          onPressed: () async {
                            final success = await viewModel.toggleFollow(bookBoxId!);
                            if (success) {
                              Get.snackbar(
                                viewModel.isFollowed ? 'Following' : 'Unfollowed',
                                viewModel.isFollowed
                                    ? 'You are now following this BookBox'
                                    : 'You have unfollowed this BookBox',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: viewModel.isFollowed ? Colors.green : Colors.orange,
                                colorText: Colors.white,
                              );
                            } else {
                              Get.snackbar(
                                'Error',
                                'Failed to ${viewModel.isFollowed ? 'unfollow' : 'follow'} BookBox',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                          icon: Icon(
                            viewModel.isFollowed ? Icons.favorite : Icons.favorite_border,
                            color: viewModel.isFollowed ? Colors.red : Color.fromRGBO(101, 67, 33, 1),
                          ),
                          tooltip: viewModel.isFollowed ? 'Unfollow BookBox' : 'Follow BookBox',
                        ),
                    ],
                  ), */
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(bookBox.latitude, bookBox.longitude),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(bookBox.id),
                            position: LatLng(bookBox.latitude, bookBox.longitude),
                            infoWindow: InfoWindow(title: bookBox.name),
                          ),
                        },
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        mapToolbarEnabled: false,
                        myLocationButtonEnabled: false,
                                                onTap: (_) {
                          if (bookBox.infoText != null && bookBox.infoText!.isNotEmpty) {
                            _showInfoDialog(bookBox);
                          } else {
                            _openGoogleMapsApp(bookBox.latitude, bookBox.longitude);
                          }
                        },
                      ),
                      // Info button overlay
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              if (bookBox.infoText != null && bookBox.infoText!.isNotEmpty) {
                                _showInfoDialog(bookBox);
                              } else {
                                _openGoogleMapsApp(bookBox.latitude, bookBox.longitude);
                              }
                            },
                            icon: const Icon(
                              Icons.directions,
                              color: LinoColors.accent,
                              size: 20,
                            ),
                            tooltip: 'Map interaction help',
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BookBox bookBox) {
    List<Widget> buttons = [];

    if (canInteract) {
      buttons.addAll([
        Expanded(child: _buildAddBookButton(bookBox.isActive)),
        const SizedBox(width: 12),
        Expanded(child: _buildRemoveBookButton(bookBox.isActive)),
      ]);
    }

    if (buttons.isEmpty) return const SizedBox.shrink();
    return Row(children: buttons);
  }

  Widget _buildAddBookButton(bool isActive) {
    return ElevatedButton.icon(
      onPressed: isActive ? () {
        Get.to(
          () => BarcodeScannerPage(addingBook: true, bookboxId: bookBoxId!),
        );
      } : () {
        Get.snackbar(
          'BookBox Under Maintenance',
          'Cannot add books while BookBox is deactivated for maintenance',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      },
      icon: Icon(Icons.add, color: isActive ? Colors.white : Colors.grey.shade400),
      label: Text(
        'Add Book',
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade400,
          fontFamily: 'Kanit',
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.green.shade600 : Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isActive ? 3 : 1,
      ),
    );
  }

  Widget _buildRemoveBookButton(bool isActive) {
    return ElevatedButton.icon(
      onPressed: isActive ? () {
        Get.to(
          () => BarcodeScannerPage(addingBook: false, bookboxId: bookBoxId!),
        );
      } : () {
        Get.snackbar(
          'BookBox Under Maintenance',
          'Cannot remove books while BookBox is deactivated for maintenance',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      },
      icon: Icon(Icons.remove, color: isActive ? Colors.white : Colors.grey.shade400),
      label: Text(
        'Take Book',
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade400,
          fontFamily: 'Kanit',
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.red.shade600 : Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isActive ? 3 : 1,
      ),
    );
  }

  Widget _buildBooksSection(BookBox bookBox) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: LinoColors.lightContainer,
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.library_books, color: LinoColors.accent, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Books Available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kanit',
                    color: LinoColors.accent,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: LinoColors.accent.withAlpha(400),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${bookBox.books.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kanit',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (bookBox.books.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                child: const Column(
                  children: [
                    Icon(Icons.book_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No books available',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Kanit',
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: bookBox.books.length,
                itemBuilder: (context, index) {
                  Book book = bookBox.books[index];
                  ExtendedBook extendedBook = ExtendedBook.fromBook(book, bookBox.id, bookBox.name);
                  return _buildBookCard(extendedBook);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(ExtendedBook book) {
    String title = book.title;
    List<String> authors = book.authors;
    String authorsString = authors.isNotEmpty ? authors.join(', ') : 'Unknown Author';
    String timeAgo = _getTimeAgo(book.dateAdded);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          Get.to(
            () => BookDetailsPage(book: book, fromBookbox: true)
            );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
                  child: book.coverImage != null && book.coverImage!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      book.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildBookPlaceholder(title);
                      },
                    ),
                  )
                      : _buildBookPlaceholder(title),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kanit',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authorsString,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontFamily: 'Kanit',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Added $timeAgo',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[500],
                        fontFamily: 'Kanit',
                      ),
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

  Widget _buildBookPlaceholder(String title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
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

  Future<void> _openGoogleMapsApp(double latitude, double longitude) async {
    if (Platform.isIOS) {
      await _showNavigationOptionsIOS(latitude, longitude);
    } else {
      await _openGoogleMapsAndroid(latitude, longitude);
    }
  }

  Future<void> _showNavigationOptionsIOS(double latitude, double longitude) async {
    final List<Map<String, dynamic>> navigationApps = [];
    
    navigationApps.add({
      'name': 'Apple Maps',
      'url': 'maps://?daddr=$latitude,$longitude&dirflg=d',
      'icon': Icons.map,
    });
    
    final googleMapsUrl = 'comgooglemaps://?daddr=$latitude,$longitude&directionsmode=driving';
    if (await canLaunchUrlString(googleMapsUrl)) {
      navigationApps.add({
        'name': 'Google Maps',
        'url': googleMapsUrl,
        'icon': Icons.navigation,
      });
    }
    
    if (navigationApps.length == 1) {
      await _launchNavigationApp(navigationApps.first['url'], navigationApps.first['name']);
    } else {
      await _showNativeActionSheet(navigationApps);
    }
  }
  
  Future<void> _showNativeActionSheet(List<Map<String, dynamic>> navigationApps) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Choose Navigation App'),
          actions: navigationApps.map((app) {
            return CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _launchNavigationApp(app['url'], app['name']);
              },
              child: Text(app['name'] as String),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }
  
  Future<void> _launchNavigationApp(String url, String appName) async {
    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        throw 'Could not open $appName';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open $appName. Please make sure it\'s installed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Future<void> _openGoogleMapsAndroid(double latitude, double longitude) async {
    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';

    try {
      if (await canLaunchUrlString(googleMapsUrl)) {
        await launchUrlString(googleMapsUrl);
      } else {
        throw 'Could not open the map.';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open Google Maps',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
