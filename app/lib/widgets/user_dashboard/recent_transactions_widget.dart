import 'package:Lino_app/models/search_model.dart';
import 'package:Lino_app/models/user_model.dart';
import 'package:Lino_app/services/bookbox_services.dart';
import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../services/transaction_services.dart';
import '../../views/profile/transactions_page.dart';

class RecentTransactionsCard extends StatefulWidget {
  final User user;

  const RecentTransactionsCard({
    super.key,
    required this.user,
  });

  @override
  _RecentTransactionsCardState createState() => _RecentTransactionsCardState();
}

class _RecentTransactionsCardState extends State<RecentTransactionsCard> {
  List<Transaction> transactions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final transactionService = TransactionServices();
      final bookboxService = BookboxService();
      
      // Fetch transactions
      SearchModel<Transaction> searchResults = await transactionService.getUserTransactions(
        widget.user.username,
        limit: 10, // Show 10 most recent transactions
      );

      final fetchedTransactions = searchResults.results;

      // Get unique bookbox IDs
      final uniqueBookboxIds = fetchedTransactions
          .map((t) => t.bookboxId)
          .toSet()
          .toList();

      // Fetch bookbox names efficiently
      final Map<String, String> bookboxNames = {};
      for (String bookboxId in uniqueBookboxIds) {
        try {
          final bookboxData = await bookboxService.getBookBox(bookboxId);
          bookboxNames[bookboxId] = bookboxData.name;
        } catch (e) {
          print('Error fetching bookbox $bookboxId: $e');
          // Continue with other bookboxes even if one fails
        }
      }

      // Update transactions with bookbox names
      final transactionsWithNames = fetchedTransactions.map((transaction) {
        final bookboxName = bookboxNames[transaction.bookboxId];
        return transaction.copyWith(bookboxName: bookboxName);
      }).toList();

      setState(() {
        transactions = transactionsWithNames;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load transactions';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Your Bookbox Trail',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TransactionsPage(user: widget.user),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 8),
              Text(
                error!,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadTransactions,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.history, color: Colors.grey, size: 48),
              SizedBox(height: 8),
              Text(
                'No transactions yet',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Start adding or taking books to see your transaction history!',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isAdded = transaction.action.toLowerCase() == 'added';
    final actionColor = isAdded ? Colors.green : Colors.orange;

    return ListTile(
      /*
      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      leading: CircleAvatar(
        backgroundColor: actionColor.withValues(alpha: 0.1),
        
        child: Icon(
          actionIcon,
          color: actionColor,
          size: 20,
        ), 
      ),
      */
      title: Text(
        'ISBN : ${transaction.isbn}',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _buildSubtitleText(transaction),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
