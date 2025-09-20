import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/vm/books/book_details_view_model.dart';
import 'package:Lino_app/views/bookboxes/book_box_page.dart';
import 'package:intl/intl.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/l10n/app_localizations.dart';

class BookDetailsPage extends StatefulWidget {
  final ExtendedBook book;
  final bool fromBookbox;

  const BookDetailsPage({super.key, required this.book, this.fromBookbox = false});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<BookDetailsViewModel>();
      viewModel.setBook(widget.book);
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
      create: (_) => BookDetailsViewModel(),
      child: Consumer<BookDetailsViewModel>(
        builder: (context, viewModel, child) {
          // Set the book when the provider is created
          if (viewModel.book == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              viewModel.setBook(widget.book);
            });
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.bookDetails,
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
                          AppLocalizations.of(context)!.swipeForDetails,
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
            ? LinoColors.accent
            : Colors.grey[400],
      ),
    );
  }

  Widget _buildFirstPage(BookDetailsViewModel viewModel) {
    final book = viewModel.book ?? widget.book;
    
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
                  // Book cover
                  Container(
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: book.coverImage != null && book.coverImage!.isNotEmpty
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
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kanit',
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // Authors
                  Text(
                    book.authors.join(', '),
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Kanit',
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Publication year
                  if (book.parutionYear != null)
                    Text(
                      book.parutionYear.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Kanit',
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Categories card
          if (book.categories.isNotEmpty)
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
                          color: Colors.black,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.categories,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kanit',
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: book.categories.map((category) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: LinoColors.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecondPage(BookDetailsViewModel viewModel) {
    final book = viewModel.book ?? widget.book;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Description card
          if (book.description != null && book.description!.isNotEmpty)
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
                    const SizedBox(height: 12),
                    _buildExpandableDescription(book.description!, viewModel),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          
          // Book info card
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
                  
                  if (book.publisher != null && book.publisher!.isNotEmpty)
                    _buildInfoRow(AppLocalizations.of(context)!.publisher, book.publisher!),
                  
                  if (book.pages != null)
                    _buildInfoRow(AppLocalizations.of(context)!.pages, book.pages.toString()),
                    
                  
                  _buildInfoRow(AppLocalizations.of(context)!.added, DateFormat('MMM dd, yyyy').format(book.dateAdded)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Bookbox location card (only show when not coming from bookbox to prevent loops)
          if (!widget.fromBookbox)
            _buildBookboxLocationCard(),
          
          if (!widget.fromBookbox)
            const SizedBox(height: 20),
          
          // Book stats card
          _buildBookStatsCard(viewModel),
        ],
      ),
    );
  }

  Widget _buildExpandableDescription(String description, BookDetailsViewModel viewModel) {
    const int maxLines = 5;
    
    // Simple approach: show expand/collapse button if description is long enough
    final shouldShowExpandButton = description.length > 200;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Kanit',
            color: LinoColors.accent,
          ),
          maxLines: viewModel.isDescriptionExpanded ? null : maxLines,
          overflow: viewModel.isDescriptionExpanded ? null : TextOverflow.ellipsis,
        ),
        if (shouldShowExpandButton)
          GestureDetector(
            onTap: () => viewModel.toggleDescriptionExpanded(),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    viewModel.isDescriptionExpanded ? AppLocalizations.of(context)!.showLess : AppLocalizations.of(context)!.showMore,
                    style: const TextStyle(
                      color: LinoColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'Kanit',
                    ),
                  ),
                  Icon(
                    viewModel.isDescriptionExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: LinoColors.accent,
                    size: 16,
                  ),
                ],
              ),
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
                color: Colors.black,
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

  Widget _buildBookStatsCard(BookDetailsViewModel viewModel) {
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
                const Icon(
                  Icons.analytics,
                  color: LinoColors.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.bookStatistics,
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
            
            if (viewModel.isLoadingStats)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(101, 67, 33, 1)),
                ),
              )
            else if (viewModel.statsError != null)
              Text(
                AppLocalizations.of(context)!.unableToLoadStatistics,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Kanit',
                  color: Colors.grey[600],
                ),
              )
            else if (viewModel.bookStats != null)
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      AppLocalizations.of(context)!.timesAdded,
                      viewModel.bookStats!.totalAdded.toString(),
                      Icons.add_circle_outline,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      AppLocalizations.of(context)!.timesTaken,
                      viewModel.bookStats!.totalTook.toString(),
                      Icons.remove_circle_outline,
                      Colors.red,
                    ),
                  ),
                ],
              )
            else
              Text(
                AppLocalizations.of(context)!.noStatisticsAvailable,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Kanit',
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit',
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Kanit',
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit',
            ),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildBookboxLocationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to bookbox page, replacing current page to maintain proper navigation flow
          Get.off(
            () => const BookBoxPage(),
            arguments: {
              'bookboxId': widget.book.bookboxId,
              'canInteract': false,
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color.fromRGBO(250, 250, 240, 1),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color.fromRGBO(101, 67, 33, 1),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.availableAtBookBox,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kanit',
                      color: Color.fromRGBO(101, 67, 33, 1),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(242, 226, 196, 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(101, 67, 33, 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.library_books,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.book.bookboxName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Kanit',
                              color: Color.fromRGBO(101, 67, 33, 1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.tapToViewBookBoxDetails,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Kanit',
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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
}
