import 'package:flutter/material.dart';
import 'package:Lino_app/models/search_model.dart';
import 'package:Lino_app/services/bookbox_services.dart';
import 'package:Lino_app/models/transaction_model.dart';
import 'package:Lino_app/services/transaction_services.dart';
import 'package:Lino_app/models/user_model.dart';

class TransactionsPage extends StatefulWidget {
  final User user;
  
  const TransactionsPage({super.key, required this.user});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
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
      
      SearchModel<Transaction> searchResults = await transactionService.getUserTransactions(
        widget.user.username,
        limit: 100, 
      );

      final fetchedTransactions = searchResults.results;

      final uniqueBookboxIds = fetchedTransactions
          .map((t) => t.bookboxId)
          .toSet()
          .toList();

      final Map<String, String> bookboxNames = {};
      for (String bookboxId in uniqueBookboxIds) {
        try {
          final bookboxData = await bookboxService.getBookBox(bookboxId);
          bookboxNames[bookboxId] = bookboxData.name;
        } catch (e) {
          print('Error fetching bookbox $bookboxId: $e');
        }
      }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading && transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTransactions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (transactions.isEmpty) {
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

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildTransactionItem(transaction);
        },
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