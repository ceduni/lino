// app/lib/views/forum/requests_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/forum/requests_view_model.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/models/request_model.dart';
import 'package:Lino_app/models/search_model.dart';
import 'package:Lino_app/views/forum/request_form.dart';

class RequestsSection extends StatefulWidget {
  const RequestsSection({super.key});

  @override
  State<RequestsSection> createState() => _RequestsSectionState();
}

class _RequestsSectionState extends State<RequestsSection> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RequestsViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: Stack(
            children: [
              Container(
                color: LinoColors.primary,
                child: Column(
                  children: [
                    _buildSearchAndFilters(viewModel),
                    Expanded(child: _buildBody(viewModel)),
                    if (viewModel.pagination != null && viewModel.requests.isNotEmpty) _buildPaginationControls(viewModel),
                  ],
                ),
              ),
              if (viewModel.isAuthenticated)
                Positioned(
                  right: 16,
                  bottom: viewModel.pagination != null ? 80 : 16,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RequestFormPage(),
                        ),
                      );
                    },
                    backgroundColor: LinoColors.accent,
                    foregroundColor: LinoColors.primary,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Create Request',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilters(RequestsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search book titles...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        viewModel.setSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              // Debounce search to avoid too many API calls
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchController.text == value) {
                  viewModel.setSearchQuery(value);
                }
              });
            },
          ),
          const SizedBox(height: 12),
          // Filter and sort controls
          Row(
            children: [
              const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: DropdownButton<RequestFilter>(
                  value: viewModel.currentFilter,
                  onChanged: (filter) {
                    if (filter != null) {
                      viewModel.setFilter(filter);
                    }
                  },
                  items: viewModel.availableFilters.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(_getShortFilterText(filter)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 16),
              const Text('Sort: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: DropdownButton<RequestSortBy>(
                  value: viewModel.sortBy,
                  onChanged: (sortBy) {
                    if (sortBy != null) {
                      viewModel.setSorting(sortBy, viewModel.sortOrder);
                    }
                  },
                  items: RequestSortBy.values.map((sortBy) {
                    return DropdownMenuItem(
                      value: sortBy,
                      child: Text(_getShortSortText(sortBy)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final newOrder = viewModel.sortOrder == SortOrder.asc 
                      ? SortOrder.desc 
                      : SortOrder.asc;
                  viewModel.setSorting(viewModel.sortBy, newOrder);
                },
                child: Icon(
                  viewModel.sortOrder == SortOrder.asc 
                      ? Icons.arrow_upward 
                      : Icons.arrow_downward,
                  color: LinoColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(RequestsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
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
                  onPressed: viewModel.refresh,
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
      );
    }

    if (viewModel.requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: LinoColors.accent),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateTitle(viewModel),
              style: TextStyle(
                fontSize: 18,
                color: LinoColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateSubtitle(viewModel),
              style: TextStyle(
                fontSize: 14,
                color: LinoColors.accent.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (!viewModel.isAuthenticated) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: LinoColors.accent,
                  foregroundColor: LinoColors.primary,
                ),
                child: const Text('Login to Create Requests'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: viewModel.requests.length,
        itemBuilder: (context, index) {
          final request = viewModel.requests[index];
          final isOwner = viewModel.isRequestOwner(request);

          return GestureDetector(
            onLongPress: isOwner
                ? () => _showDeleteDialog(context, viewModel, request)
                : null,
            child: isOwner
                ? Dismissible(
                    key: Key(request.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (isOwner) {
                        return await _showDeleteDialog(context, viewModel, request);
                      }
                      return false;
                    },
                    child: _buildRequestCard(request, isOwner),
                  )
                : _buildRequestCard(request, isOwner),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(Request request, bool isOwner) {
    return Consumer<RequestsViewModel>(
      builder: (context, viewModel, child) {
        final canLike = viewModel.canLikeRequest(request);
        final isLiked = viewModel.isRequestLikedByUser(request);
        
        return Card(
          color: isOwner ? LinoColors.accent : LinoColors.secondary,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListTile(
            onTap: () => showRequestDetails(request),
            title: Text(
              request.bookTitle,
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Requested by ${request.username}',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                if (request.customMessage != null && request.customMessage!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    request.customMessage!,
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Like/Upvote button or display
                    if (canLike)
                      GestureDetector(
                        onTap: () async {
                          await viewModel.toggleLike(request.id);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.thumb_up,
                              size: 20,
                              color: isLiked ? Colors.green: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${request.upvoteCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isLiked ? Colors.green : Colors.white70,
                                fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.thumb_up,
                            size: 20,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${request.upvoteCount}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(width: 16),
                    // Notified count with network/stats icon
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 18,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${request.nbPeopleNotified}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showRequestDetails(Request request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(request.bookTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Requested by: ${request.username}'),
            const SizedBox(height: 8),
            if (request.customMessage != null && request.customMessage!.isNotEmpty)
              Text('Message: ${request.customMessage}'),
            const SizedBox(height: 8),
            Text('Upvotes: ${request.upvoteCount}'),
            Text('People Notified: ${request.nbPeopleNotified}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'), 
          ),
          if (request.username == context.read<RequestsViewModel>().currentUsername) ...[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final confirmed = await _showDeleteDialog(context, context.read<RequestsViewModel>(), request);
                if (confirmed && context.mounted) {
                  Navigator.of(context).pop(); 
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildPaginationControls(RequestsViewModel viewModel) {
    final pagination = viewModel.pagination!;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${pagination.totalResults} results',
            style: TextStyle(
              color: LinoColors.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: pagination.hasPrevPage ? viewModel.previousPage : null,
                icon: const Icon(Icons.chevron_left),
                color: LinoColors.accent,
              ),
              Text(
                '${pagination.currentPage} / ${pagination.totalPages}',
                style: TextStyle(
                  color: LinoColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: pagination.hasNextPage ? viewModel.nextPage : null,
                icon: const Icon(Icons.chevron_right),
                color: LinoColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getShortFilterText(RequestFilter filter) {
    switch (filter) {
      case RequestFilter.all:
        return 'All';
      case RequestFilter.mine:
        return 'Mine';
      case RequestFilter.upvoted:
        return 'Upvoted';
      case RequestFilter.notified:
        return 'Notified';
    }
  }

  String _getShortSortText(RequestSortBy sortBy) {
    switch (sortBy) {
      case RequestSortBy.date:
        return 'Date';
      case RequestSortBy.upvoters:
        return 'Upvotes';
      case RequestSortBy.peopleNotified:
        return 'Notified';
    }
  }

  String _getEmptyStateTitle(RequestsViewModel viewModel) {
    if (viewModel.searchQuery.isNotEmpty) {
      return 'No requests found for "${viewModel.searchQuery}"';
    }
    
    switch (viewModel.currentFilter) {
      case RequestFilter.all:
        return 'No book requests found';
      case RequestFilter.mine:
        return 'You have no requests';
      case RequestFilter.upvoted:
        return 'No upvoted requests';
      case RequestFilter.notified:
        return 'No notified requests';
    }
  }

  String _getEmptyStateSubtitle(RequestsViewModel viewModel) {
    if (viewModel.searchQuery.isNotEmpty) {
      return 'Try searching for a different book title or clear your search to see all requests.';
    }
    
    switch (viewModel.currentFilter) {
      case RequestFilter.all:
        return 'Be the first to request a book!';
      case RequestFilter.mine:
        return 'Start requesting books you\'d like to read';
      case RequestFilter.upvoted:
        return 'You haven\'t upvoted any requests yet';
      case RequestFilter.notified:
        return 'You haven\'t been notified about any requests yet';
    }
  }

  Future<bool> _showDeleteDialog(BuildContext context, RequestsViewModel viewModel, Request request) async {
    final deleteConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete your request for "${request.bookTitle}"?'),
        content: const Text(
            'You won\'t be notified when the book you want will be added to a bookbox.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (deleteConfirmed == true) {
      final success = await viewModel.deleteRequest(request.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error ?? 'Failed to delete request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return deleteConfirmed ?? false;
  }
}
