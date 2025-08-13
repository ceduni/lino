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
        ),
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
    if (viewModel.searchQuery.isEmpty) {
      return const Center(
        child: Text(
          'Enter a search term to find bookboxes or books',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${viewModel.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
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
        _buildBookboxSortingFilter(viewModel),
        Expanded(
          child: viewModel.bookboxResults.isEmpty
              ? const Center(
                  child: Text(
                    'No bookboxes found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
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
        if (viewModel.bookboxPagination != null)
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: bookbox.image != null
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
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              )
            : Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.library_books),
              ),
        title: Text(
          bookbox.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  bookbox.isActive ? Icons.check_circle : Icons.cancel,
                  color: bookbox.isActive ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(bookbox.isActive ? 'Active' : 'Inactive'),
              ],
            ),
            if (bookbox.distance != null)
              Text('Distance: ${bookbox.distance!.toStringAsFixed(2)} km'),
          ],
        ),
        onTap: () => viewModel.onBookboxTap(bookbox),
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
              ? const Center(
                  child: Text(
                    'No books found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: viewModel.bookResults.length,
                  itemBuilder: (context, index) {
                    final book = viewModel.bookResults[index];
                    return _buildBookItem(book, viewModel);
                  },
                ),
        ),
        if (viewModel.bookPagination != null)
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: book.coverImage != null
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
                      color: Colors.grey[300],
                      child: const Icon(Icons.book),
                    );
                  },
                ),
              )
            : Container(
                width: 60,
                height: 80,
                color: Colors.grey[300],
                child: const Icon(Icons.book),
              ),
        title: Text(
          book.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book.authors.isNotEmpty)
              Text('By: ${book.authors.join(', ')}'),
            Text('In: ${book.bookboxName}'),
          ],
        ),
        onTap: () => viewModel.onBookTap(book),
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
