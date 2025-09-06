import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/profile/transactions_view_model.dart';
import 'package:Lino_app/models/user_model.dart';

import '../../models/transaction_model.dart';

class TransactionsPage extends StatefulWidget {
  final User user;

  const TransactionsPage({super.key, required this.user});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsViewModel>().initialize(widget.user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Transaction History'),
            foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          ),
          body: _buildBody(viewModel),
        );
      },
    );
  }

  Widget _buildBody(TransactionsViewModel viewModel) {
    if (viewModel.showLoadingIndicator) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError && !viewModel.hasTransactions) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              viewModel.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.refreshTransactions(widget.user),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!viewModel.hasTransactions) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start adding or taking books to see your transaction history!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Transaction count header
        if (viewModel.pagination != null)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${viewModel.pagination!.totalResults} transactions total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

        // Transactions list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => viewModel.refreshTransactions(widget.user),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viewModel.transactions.length + (viewModel.showBottomLoading ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index == viewModel.transactions.length) {
                  // Loading indicator at the bottom when loading more
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final transaction = viewModel.transactions[index];
                return _buildTransactionItem(transaction);
              },
            ),
          ),
        ),

        // Pagination controls
        if (viewModel.hasPagination)
          _buildPaginationControls(viewModel),
      ],
    );
  }

  Widget _buildPaginationControls(TransactionsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Page info and navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page ${viewModel.pagination!.currentPage} of ${viewModel.pagination!.totalPages}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: viewModel.pagination!.hasPrevPage && !viewModel.isLoading
                        ? () => viewModel.loadPreviousPage(widget.user)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous page',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: viewModel.pagination!.hasNextPage && !viewModel.isLoading
                        ? () => viewModel.loadNextPage(widget.user)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next page',
                  ),
                ],
              ),
            ],
          ),

          // Page selector for small number of pages
          if (viewModel.pagination!.totalPages <= 10)
            const SizedBox(height: 8),
          if (viewModel.pagination!.totalPages <= 10)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(viewModel.pagination!.totalPages, (index) {
                  final pageNumber = index + 1;
                  final isCurrentPage = pageNumber == viewModel.pagination!.currentPage;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onTap: isCurrentPage || viewModel.isLoading
                          ? null
                          : () => viewModel.goToPage(widget.user, pageNumber),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isCurrentPage ? Colors.blue : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCurrentPage ? Colors.blue : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          pageNumber.toString(),
                          style: TextStyle(
                            color: isCurrentPage ? Colors.white : Colors.black,
                            fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isAdded = transaction.action.toLowerCase() == 'added';
    final actionColor = isAdded ? Colors.green : Colors.orange;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        title: Text(
          transaction.bookTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _buildSubtitleText(transaction),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: actionColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            transaction.actionDisplayText,
            style: TextStyle(
              color: actionColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  String _buildSubtitleText(Transaction transaction) {
    final parts = <String>[
      transaction.timeAgo,
    ];

    if (transaction.bookboxName != null && transaction.bookboxName!.isNotEmpty) {
      parts.insert(1, 'at ${transaction.bookboxName}');
    }

    return parts.join(' • ');
  }
}