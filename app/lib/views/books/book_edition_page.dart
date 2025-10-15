import 'package:Lino_app/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/vm/books/book_edition_view_model.dart';
import 'package:Lino_app/views/books/camera_page.dart';
import 'package:intl/intl.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/l10n/app_localizations.dart';

class BookEditionPage extends StatefulWidget {
  final String bookboxId;
  final EditableBook editableBook;

  const BookEditionPage({
    super.key,
    required this.bookboxId,
    required this.editableBook,
  });

  @override
  State<BookEditionPage> createState() => _BookEditionPageState();
}

class _BookEditionPageState extends State<BookEditionPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<BookEditionViewModel>();
      viewModel.initializeBook(widget.editableBook);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookEditionViewModel(),
      child: Consumer<BookEditionViewModel>(
        builder: (context, viewModel, child) {
          // Initialize the book when the provider is created
          if (!viewModel.isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              viewModel.initializeBook(widget.editableBook);
            });
          }

          return Scaffold(
            backgroundColor: LinoColors.lightContainer,
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.editBookDetails,
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: LinoColors.accent,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Page indicator
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPageIndicator(0),
                        const SizedBox(width: 8),
                        _buildPageIndicator(1),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.swipe_left,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.swipetoeditmore,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // PageView
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        _buildFirstPage(viewModel),
                        _buildSecondPage(viewModel),
                      ],
                    ),
                  ),
                  // Confirm button
                  _buildConfirmButton(viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(int pageIndex) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == pageIndex
            ? const Color.fromRGBO(101, 67, 33, 1)
            : Colors.grey[400],
      ),
    );
  }

  Widget _buildFirstPage(BookEditionViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Book cover and basic info card
          Card(
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Book cover with edit option
                  GestureDetector(
                    onTap: () => _showCoverImageOptions(viewModel),
                    child: Container(
                      width: 200,
                      height: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildCoverImage(viewModel),
                          ),
                          // Edit overlay
                          if (_isDefaultPlaceholder(viewModel.editableBook.coverImage))
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Title (editable)
                  _buildEditableTextField(
                    label: AppLocalizations.of(context)!.titleField,
                    value: viewModel.editableBook.title,
                    onChanged: (value) => viewModel.updateTitle(value),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  // Authors (editable)
                  _buildEditableTextField(
                    label: AppLocalizations.of(context)!.authorsSeparateCommas,
                    value: viewModel.editableBook.authors.join(', '),
                    onChanged: (value) => viewModel.updateAuthors(value),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  // Publication year (editable)
                  _buildEditableTextField(
                    label: AppLocalizations.of(context)!.publicationYear,
                    value: viewModel.editableBook.parutionYear?.toString() ?? '',
                    onChanged: (value) => viewModel.updateParutionYear(value),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Categories card (editable)
          Card(
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
                      const Icon(
                        Icons.category,
                        color: LinoColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.categories,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kanit',
                          color: LinoColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildEditableTextField(
                    label: AppLocalizations.of(context)!.categoriesSeparateCommas,
                    value: viewModel.editableBook.categories.join(', '),
                    onChanged: (value) => viewModel.updateCategories(value),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondPage(BookEditionViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Description card (editable)
          Card(
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
                      const Icon(
                        Icons.description,
                        color: LinoColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.description,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kanit',
                          color: LinoColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildEditableTextField(
                    label: AppLocalizations.of(context)!.bookDescription,
                    value: viewModel.editableBook.description,
                    onChanged: (value) => viewModel.updateDescription(value),
                    maxLines: 6,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Book info card (editable)
          Card(
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
                      const Icon(
                        Icons.info,
                        color: LinoColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.bookInformation,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kanit',
                          color: LinoColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Publisher (editable)
                  _buildEditableTextField(
                    label: AppLocalizations.of(context)!.publisher,
                    value: viewModel.editableBook.publisher,
                    onChanged: (value) => viewModel.updatePublisher(value),
                  ),
                  const SizedBox(height: 16),
                  
                  // Pages (editable)
                  _buildEditableTextField(
                    label: AppLocalizations.of(context)!.numberOfPages,
                    value: viewModel.editableBook.pages?.toString() ?? '',
                    onChanged: (value) => viewModel.updatePages(value),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  
                  // Added date (read-only, defaults to today)
                  _buildInfoRow(AppLocalizations.of(context)!.added, DateFormat('MMM dd, yyyy').format(DateTime.now())),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Kanit',
            color: Color.fromRGBO(101, 67, 33, 1),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Kanit',
            color: Color.fromRGBO(101, 67, 33, 1),
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color.fromRGBO(101, 67, 33, 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color.fromRGBO(101, 67, 33, 1), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Kanit',
                color: Color.fromRGBO(101, 67, 33, 1),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Kanit',
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(BookEditionViewModel viewModel) {
    if (viewModel.isUploadingImage) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(101, 67, 33, 1)),
          ),
        ),
      );
    }

    if (viewModel.editableBook.coverImage.isNotEmpty && 
        !_isDefaultPlaceholder(viewModel.editableBook.coverImage)) {
      return Image.network(
        viewModel.editableBook.coverImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildBookPlaceholder(viewModel.editableBook.title);
        },
      );
    }

    return _buildBookPlaceholder(viewModel.editableBook.title);
  }

  Widget _buildBookPlaceholder(String title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[400]!, Colors.grey[600]!],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.tapToAddCover,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Kanit',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Kanit',
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BookEditionViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: viewModel.isLoading ? null : () => _confirmAddBook(viewModel),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          child: viewModel.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  AppLocalizations.of(context)!.confirmAddToBookBox,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  bool _isDefaultPlaceholder(String coverImage) {
    return coverImage.isEmpty || 
           coverImage == AppLocalizations.of(context)!.noThumbnailAvailable ||
           coverImage == AppLocalizations.of(context)!.noCoverAvailable;
  }

  void _showCoverImageOptions(BookEditionViewModel viewModel) {
    if (!_isDefaultPlaceholder(viewModel.editableBook.coverImage)) {
      return; // Don't show options if there's already a valid image
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.addBookCover,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Kanit',
                color: Color.fromRGBO(101, 67, 33, 1),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color.fromRGBO(101, 67, 33, 1)),
              title: Text(
                AppLocalizations.of(context)!.takePhoto,
                style: TextStyle(fontFamily: 'Kanit'),
              ),
              onTap: () {
                Get.back();
                _takeCoverPhoto(viewModel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.grey),
              title: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(fontFamily: 'Kanit'),
              ),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  void _takeCoverPhoto(BookEditionViewModel viewModel) async {
    final result = await Get.to(() => const CameraPage());
    if (result != null && result is String) {
      viewModel.updateCoverImage(result);
    }
  }

  void _confirmAddBook(BookEditionViewModel viewModel) async {
    try {
      await viewModel.addBookToBookBox(widget.bookboxId);

      // Navigate back to previous screens immediately
      Get.back(); // Go back from book edition page
      Get.back(); // Go back from barcode scanner page to main bookbox page

      // Show success message
      CustomSnackbars.success(
        AppLocalizations.of(context)!.success,
        AppLocalizations.of(context)!.bookAddedSuccessfully,
      );
    } catch (e) {
      // Show error message
      CustomSnackbars.error(
        AppLocalizations.of(context)!.error,
        AppLocalizations.of(context)!.failedToAddBook(e.toString()),
      );
    }
  }
}
