import 'package:flutter/material.dart';
import 'package:Lino_app/models/search_model.dart';
import 'package:Lino_app/services/bookbox_services.dart';
import 'package:Lino_app/models/transaction_model.dart';
import 'package:Lino_app/services/transaction_services.dart';
import 'package:Lino_app/models/user_model.dart';

class TransactionsViewModel extends ChangeNotifier {
  final TransactionServices _transactionService = TransactionServices();
  final BookboxService _bookboxService = BookboxService();

  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;
  Pagination? _pagination;
  int _currentPage = 1;
  static const int _pageSize = 20;

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Pagination? get pagination => _pagination;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  // Initialize with user data
  Future<void> initialize(User user) async {
    await loadTransactions(user);
  }

  Future<void> loadTransactions(User user, {int page = 1, bool append = false}) async {
    try {
      _setLoading(true, append);
      if (!append) {
        _error = null;
      }

      SearchModel<Transaction> searchResults = await _transactionService.searchTransactions(
        username: user.username,
        limit: _pageSize,
        page: page,
      );

      final fetchedTransactions = searchResults.results;

      // Get unique bookbox IDs from fetched transactions
      final uniqueBookboxIds = fetchedTransactions
          .map((t) => t.bookboxId)
          .toSet()
          .toList();

      // Fetch bookbox names for the new transactions
      final Map<String, String> bookboxNames = {};
      for (String bookboxId in uniqueBookboxIds) {
        try {
          final bookboxData = await _bookboxService.getBookBox(bookboxId);
          bookboxNames[bookboxId] = bookboxData.name;
        } catch (e) {
          print('Error fetching bookbox $bookboxId: $e');
        }
      }

      final transactionsWithNames = fetchedTransactions.map((transaction) {
        final bookboxName = bookboxNames[transaction.bookboxId];
        return transaction.copyWith(bookboxName: bookboxName);
      }).toList();

      if (append) {
        _transactions.addAll(transactionsWithNames);
      } else {
        _transactions = transactionsWithNames;
      }

      _pagination = searchResults.pagination;
      _currentPage = page;
      _setLoading(false, append);
    } catch (e) {
      _error = 'Failed to load transactions';
      _setLoading(false, append);
      print('Error loading transactions: $e');
    }
  }

  Future<void> refreshTransactions(User user) async {
    _currentPage = 1;
    await loadTransactions(user, page: 1, append: false);
  }

  Future<void> loadNextPage(User user) async {
    if (_pagination != null && _pagination!.hasNextPage && !_isLoading) {
      await loadTransactions(user, page: _currentPage + 1, append: true);
    }
  }

  Future<void> loadPreviousPage(User user) async {
    if (_pagination != null && _pagination!.hasPrevPage && !_isLoading && _currentPage > 1) {
      await loadTransactions(user, page: _currentPage - 1, append: false);
    }
  }

  Future<void> goToPage(User user, int page) async {
    if (page >= 1 &&
        page <= (_pagination?.totalPages ?? 1) &&
        page != _currentPage &&
        !_isLoading) {
      await loadTransactions(user, page: page, append: false);
    }
  }

  void _setLoading(bool loading, bool append) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper methods for UI
  bool get hasTransactions => _transactions.isNotEmpty;
  bool get hasError => _error != null;
  bool get hasPagination => _pagination != null && _pagination!.totalPages > 1;
  bool get showLoadingIndicator => _isLoading && _transactions.isEmpty;
  bool get showBottomLoading => _isLoading && _transactions.isNotEmpty;
}