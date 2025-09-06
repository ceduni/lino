// app/lib/views/search/search_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/search/search_page_view_model.dart';
import 'package:Lino_app/utils/constants/search_types.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/models/bookbox_model.dart';
import 'package:Lino_app/models/book_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchPageViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchPageViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: Column(
            children: [
              _buildSearchBar(viewModel),
              _buildSearchTypeTabs(viewModel),
              Expanded(
                child: _buildSearchResults(viewModel),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(SearchPageViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: viewModel.searchController,
        decoration: InputDecoration(
          hintText: 'Search ${viewModel.currentSearchType == SearchType.bookboxes ? 'bookboxes' : 'books'}...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          suffixIcon: viewModel.searchController.text.isNotEmpty ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: viewModel.searchController.clear
          ): null
        ) ,
      ),
    );
  }

  Widget _buildSearchTypeTabs(SearchPageViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => viewModel.switchSearchType(SearchType.bookboxes),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: viewModel.currentSearchType == SearchType.bookboxes
                      ? LinoColors.accent
                      : Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Bookboxes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: viewModel.currentSearchType == SearchType.bookboxes
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => viewModel.switchSearchType(SearchType.books),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: viewModel.currentSearchType == SearchType.books
                      ? LinoColors.accent
                      : Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Books',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: viewModel.currentSearchType == SearchType.books
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchPageViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                viewModel.error!,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: viewModel.retrySearch,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LinoColors.accent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: viewModel.clearError,
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Show nearby bookboxes when search query is empty and we're on bookboxes tab
    if (viewModel.searchQuery.isEmpty && viewModel.currentSearchType == SearchType.bookboxes) {
      return Column(
        children: [
          // Header for nearby bookboxes
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.location_on, color: LinoColors.accent),
                const SizedBox(width: 8),
                const Text(
                  'Bookboxes near you',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: viewModel.loadNearbyBookboxes,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh nearby bookboxes',
                ),
              ],
            ),
          ),
          Expanded(
            child: viewModel.bookboxResults.isEmpty
                ? const Center(
                    child: Text(
                      'No bookboxes found in your area, try manually searching for one.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : _buildBookboxResults(viewModel),
          ),
        ],
      );
    }

    // Show empty state for books or when search query is empty for books
    if (viewModel.searchQuery.isEmpty) {
      return const Center(
        child: Text(
          'Enter a search term to find bookboxes or books',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return viewModel.currentSearchType == SearchType.bookboxes
        ? _buildBookboxResults(viewModel)
        : _buildBookResults(viewModel);
  }

  Widget _buildBookboxResults(SearchPageViewModel viewModel) {
    return Column(
      children: [
        // Only show sorting filter when there's a search query
        if (viewModel.searchQuery.isNotEmpty)
          _buildBookboxSortingFilter(viewModel),
        Expanded(
          child: viewModel.bookboxResults.isEmpty
              ? Center(
                  child: Text(
                    viewModel.searchQuery.isEmpty 
                      ? 'No bookboxes found in your area, try manually searching for one.'
                      : 'No bookboxes found',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: viewModel.bookboxResults.length,
                  itemBuilder: (context, index) {
                    final bookbox = viewModel.bookboxResults[index];
                    return _buildBookboxItem(bookbox, viewModel);
                  },
                ),
        ),
        if (viewModel.bookboxPagination != null && viewModel.bookboxResults.isNotEmpty)
          _buildBookboxPagination(viewModel),
      ],
    );
  }

  Widget _buildBookboxSortingFilter(SearchPageViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: DropdownButton<SortOption>(
              value: viewModel.bookboxSortOption,
              onChanged: (SortOption? newValue) {
                if (newValue != null) {
                  viewModel.setBookboxSort(newValue, viewModel.bookboxAscending);
                }
              },
              items: viewModel.getBookboxSortOptions().map((SortOption option) {
                return DropdownMenuItem<SortOption>(
                  value: option,
                  child: Text(option.value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => viewModel.setBookboxSort(
              viewModel.bookboxSortOption,
              !viewModel.bookboxAscending,
            ),
            child: Icon(
              viewModel.bookboxAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: LinoColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookboxItem(ShortenedBookBox bookbox, SearchPageViewModel viewModel) {
    // Color scheme based on active status
    final backgroundColor = bookbox.isActive 
        ? Colors.green.shade50 
        : Colors.red.shade50;
    final borderColor = bookbox.isActive 
        ? Colors.green.shade200 
        : Colors.red.shade200;
    final statusColor = bookbox.isActive 
        ? Colors.green.shade700 
        : Colors.red.shade700;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          leading: Stack(
            children: [
              bookbox.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        bookbox.image!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(Icons.library_books),
                    ),
              // Status indicator dot
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  bookbox.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              // Books count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: LinoColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.book, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${bookbox.booksCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Status with visual indicator
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    bookbox.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              // Distance if available
              if (bookbox.distance != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${bookbox.distance!.toStringAsFixed(1)} km away',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          onTap: () => viewModel.onBookboxTap(bookbox),
        ),
      ),
    );
  }

  Widget _buildBookboxPagination(SearchPageViewModel viewModel) {
    final pagination = viewModel.bookboxPagination!;
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${pagination.totalResults} results'),
          Row(
            children: [
              IconButton(
                onPressed: pagination.hasPrevPage
                    ? () => viewModel.previousBookboxPage()
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('${pagination.currentPage} / ${pagination.totalPages}'),
              IconButton(
                onPressed: pagination.hasNextPage
                    ? () => viewModel.nextBookboxPage()
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookResults(SearchPageViewModel viewModel) {
    return Column(
      children: [
        _buildBookSortingFilter(viewModel),
        Expanded(
          child: viewModel.bookResults.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.book, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No books found for "${viewModel.searchQuery}"',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        viewModel.createRequest(viewModel.searchQuery);
                      }, 
                      child: const Text('Create a new request for this book !', style: TextStyle(
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w600,
              color: LinoColors.accent,
            )),
                    ),
                    
                  ],
                )
              : ListView.builder(
                  itemCount: viewModel.bookResults.length,
                  itemBuilder: (context, index) {
                    final book = viewModel.bookResults[index];
                    return _buildBookItem(book, viewModel);
                  },
                ),
        ),
        if (viewModel.bookPagination != null && viewModel.bookResults.isNotEmpty)
          _buildBookPagination(viewModel),
      ],
    );
  }

  Widget _buildBookSortingFilter(SearchPageViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: DropdownButton<SortOption>(
              value: viewModel.bookSortOption,
              onChanged: (SortOption? newValue) {
                if (newValue != null) {
                  viewModel.setBookSort(newValue, viewModel.bookAscending);
                }
              },
              items: viewModel.getBookSortOptions().map((SortOption option) {
                return DropdownMenuItem<SortOption>(
                  value: option,
                  child: Text(option.value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => viewModel.setBookSort(
              viewModel.bookSortOption,
              !viewModel.bookAscending,
            ),
            child: Icon(
              viewModel.bookAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: LinoColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(ExtendedBook book, SearchPageViewModel viewModel) {
    // Gradient colors for book items
    final gradientColors = [
      Colors.blue.shade50,
      Colors.purple.shade50,
    ];
    final borderColor = Colors.blue.shade200;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          leading: Stack(
            children: [
              book.coverImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        book.coverImage!,
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Icon(Icons.book, size: 24),
                          );
                        },
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(Icons.book, size: 24),
                    ),
              // Book indicator
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            book.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Authors
              if (book.authors.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        book.authors.join(', '),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              // Bookbox location
              Row(
                children: [
                  Icon(Icons.library_books, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      book.bookboxName,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
          onTap: () => viewModel.onBookTap(book),
        ),
      ),
    );
  }

  Widget _buildBookPagination(SearchPageViewModel viewModel) {
    final pagination = viewModel.bookPagination!;
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${pagination.totalResults} results'),
          Row(
            children: [
              IconButton(
                onPressed: pagination.hasPrevPage
                    ? () => viewModel.previousBookPage()
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('${pagination.currentPage} / ${pagination.totalPages}'),
              IconButton(
                onPressed: pagination.hasNextPage
                    ? () => viewModel.nextBookPage()
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
