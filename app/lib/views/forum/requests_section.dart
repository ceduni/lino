// app/lib/views/forum/requests_section.dart
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:Lino_app/widgets/custom_snackbar.dart';
import 'package:Lino_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/forum/requests_view_model.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/models/request_model.dart';
import 'package:Lino_app/models/search_model.dart';

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
    final localizations = AppLocalizations.of(context)!;
    
    return Consumer<RequestsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: Stack(
            children: [
              Container(
                color: LinoColors.primary,
                child: Column(
                  children: [
                    _buildSearchAndFilters(viewModel, localizations),
                    Expanded(child: _buildBody(viewModel, localizations)),
                    if (viewModel.pagination != null && viewModel.requests.isNotEmpty) _buildPaginationControls(viewModel, localizations),
                  ],
                ),
              ),
              if (viewModel.isAuthenticated)
                Positioned(
                  right: 16,
                  bottom: viewModel.pagination != null ? 80 : 16,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Get.toNamed(AppRoutes.forum.request.form);
                    },
                    backgroundColor: LinoColors.accent,
                    foregroundColor: LinoColors.primary,
                    icon: const Icon(Icons.add),
                    label: Text(
                      localizations.createRequest,
                      style: const TextStyle(
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

  Widget _buildSearchAndFilters(RequestsViewModel viewModel, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: localizations.searchBookTitles,
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
              Text('${localizations.filter}: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Expanded(
                flex: 2,
                child: DropdownButton<RequestFilter>(
                  value: viewModel.currentFilter,
                  isExpanded: true,
                  onChanged: (filter) {
                    if (filter != null) {
                      viewModel.setFilter(filter);
                    }
                  },
                  items: viewModel.availableFilters.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(_getShortFilterText(filter, localizations)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              Text('${localizations.sort}: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Expanded(
                flex: 2,
                child: DropdownButton<RequestSortBy>(
                  value: viewModel.sortBy,
                  isExpanded: true,
                  onChanged: (sortBy) {
                    if (sortBy != null) {
                      viewModel.setSorting(sortBy, viewModel.sortOrder);
                    }
                  },
                  items: RequestSortBy.values.map((sortBy) {
                    return DropdownMenuItem(
                      value: sortBy,
                      child: Text(_getShortSortText(sortBy, localizations)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 4),
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

  Widget _buildBody(RequestsViewModel viewModel, AppLocalizations localizations) {
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
                  label: Text(localizations.retry),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LinoColors.accent,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: viewModel.clearError,
                  child: Text(localizations.dismiss),
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
              _getEmptyStateTitle(viewModel, localizations),
              style: TextStyle(
                fontSize: 18,
                color: LinoColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                _getEmptyStateSubtitle(viewModel, localizations),
                style: TextStyle(
                  fontSize: 14,
                  color: LinoColors.accent.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (!viewModel.isAuthenticated) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.auth.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: LinoColors.accent,
                  foregroundColor: LinoColors.primary,
                ),
                child: Text(localizations.loginToCreateRequests),
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
                ? () => _showDeleteDialog(context, viewModel, request, localizations)
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
                        return await _showDeleteDialog(context, viewModel, request, localizations);
                      }
                      return false;
                    },
                    child: _buildRequestCard(request, isOwner, localizations),
                  )
                : _buildRequestCard(request, isOwner, localizations),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(Request request, bool isOwner, AppLocalizations localizations) {
    return Consumer<RequestsViewModel>(
      builder: (context, viewModel, child) {
        final canLike = viewModel.canLikeRequest(request);
        final isLiked = viewModel.isRequestLikedByUser(request);

        
        return Card(
          margin: const EdgeInsets.all( 5.0),
          elevation: 1,
          color: LinoColors.lightContainer,
          child: ListTile(
            onTap: () => showRequestDetails(request),
            
            title: Text(
              request.bookTitle,
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w600,
                color: isOwner ? LinoColors.accent : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  isOwner ? localizations.yourRequest :
                  '${localizations.requestedBy} ${request.username}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                /** 
                if (request.customMessage != null && request.customMessage!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    request.customMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                */
                Row(
                  children: [
                    // Like/Upvote button or display
                    if (canLike)
                      GestureDetector(
                        onTap: () async {
                          await viewModel.toggleLike(request.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                size: 20,
                                color: isLiked ? LinoColors.accent : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${request.upvoteCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isLiked ? LinoColors.accent : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.thumb_up,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${request.upvoteCount}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 16),
                    // Notified count
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${request.nbPeopleNotified}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
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
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(request.bookTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${localizations.requestedBy}: ${request.username}'),
            const SizedBox(height: 8),
            if (request.customMessage != null && request.customMessage!.isNotEmpty)
              Text('${localizations.message}: ${request.customMessage}'),
            const SizedBox(height: 8),
            Text('${localizations.upvotes}: ${request.upvoteCount}'),
            const SizedBox(height: 8),
            Text('${localizations.peopleNotified} ${request.nbPeopleNotified}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(localizations.close),
          ),
          if (request.username == context.read<RequestsViewModel>().currentUsername) ...[
            TextButton(
              onPressed: () async {
                Get.back();
                final confirmed = await _showDeleteDialog(context, context.read<RequestsViewModel>(), request, localizations);
                if (confirmed && context.mounted) {
                  Get.back();
                }
              },
              child: Text(localizations.delete, style: TextStyle(color: Colors.red)),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildPaginationControls(RequestsViewModel viewModel, AppLocalizations localizations) {
    final pagination = viewModel.pagination!;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${pagination.totalResults} ${localizations.results}',
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

  String _getShortFilterText(RequestFilter filter, AppLocalizations localizations) {
    switch (filter) {
      case RequestFilter.all:
        return localizations.all;
      case RequestFilter.mine:
        return localizations.mine;
      case RequestFilter.upvoted:
        return localizations.upvoted;
      case RequestFilter.notified:
        return localizations.notified;
    }
  }

  String _getShortSortText(RequestSortBy sortBy, AppLocalizations localizations) {
    switch (sortBy) {
      case RequestSortBy.date:
        return localizations.date;
      case RequestSortBy.upvoters:
        return localizations.upvotes;
      case RequestSortBy.peopleNotified:
        return localizations.notified;
    }
  }

  String _getEmptyStateTitle(RequestsViewModel viewModel, AppLocalizations localizations) {
    if (viewModel.searchQuery.isNotEmpty) {
      return '${localizations.noRequestsFoundFor} "${viewModel.searchQuery}"';
    }
    
    switch (viewModel.currentFilter) {
      case RequestFilter.all:
        return localizations.noBookRequestsFound;
      case RequestFilter.mine:
        return localizations.youHaveNoRequests;
      case RequestFilter.upvoted:
        return localizations.noUpvotedRequests;
      case RequestFilter.notified:
        return localizations.noNotifiedRequests;
    }
  }

  String _getEmptyStateSubtitle(RequestsViewModel viewModel, AppLocalizations localizations) {
    if (viewModel.searchQuery.isNotEmpty) {
      return localizations.tryDifferentSearch;
    }
    
    switch (viewModel.currentFilter) {
      case RequestFilter.all:
        return localizations.beFirstToRequest;
      case RequestFilter.mine:
        return localizations.startRequestingBooks;
      case RequestFilter.upvoted:
        return localizations.haventUpvotedYet;
      case RequestFilter.notified:
        return localizations.haventBeenNotified;
    }
  }

  Future<bool> _showDeleteDialog(BuildContext context, RequestsViewModel viewModel, Request request, AppLocalizations localizations) async {
    final deleteConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${localizations.deleteRequestTitle}"${request.bookTitle}"?'),
        content: Text(localizations.deleteRequestContent),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(localizations.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (deleteConfirmed == true) {
      final success = await viewModel.deleteRequest(request.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.deleteRequestSuccess),
            backgroundColor: Colors.green,
          ),
        );
        CustomSnackbars.success(
          localizations.requestDeleted,
          localizations.requestDeletedMessage,
        );
      } else if (!success && context.mounted) {
        CustomSnackbars.error(
          'Error',
          localizations.failedToDeleteRequest,
        );
      }
    }

    return deleteConfirmed ?? false;
  }
}
