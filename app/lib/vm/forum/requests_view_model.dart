// app/lib/vm/forum/requests_view_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/models/request_model.dart';
import 'package:Lino_app/models/search_model.dart';
import 'package:Lino_app/services/search_services.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:Lino_app/services/book_request_services.dart';

class RequestsViewModel extends ChangeNotifier {
  final SearchService _searchService = SearchService();
  final UserService _userService = UserService();
  final BookRequestService _bookRequestService = BookRequestService();

  // State
  List<Request> _requests = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUsername;
  bool _isAuthenticated = false;
  
  // Search and pagination state
  String _searchQuery = '';
  RequestFilter _currentFilter = RequestFilter.all;
  RequestSortBy _sortBy = RequestSortBy.date;
  SortOrder _sortOrder = SortOrder.desc;
  Pagination? _pagination;
  int _currentPage = 1;
  final int _itemsPerPage = 20;

  // Getters
  List<Request> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUsername => _currentUsername;
  bool get isAuthenticated => _isAuthenticated;
  String get searchQuery => _searchQuery;
  RequestFilter get currentFilter => _currentFilter;
  RequestSortBy get sortBy => _sortBy;
  SortOrder get sortOrder => _sortOrder;
  Pagination? get pagination => _pagination;
  int get currentPage => _currentPage;

  // Available filters based on authentication status
  List<RequestFilter> get availableFilters {
    if (_isAuthenticated) {
      return RequestFilter.values;
    } else {
      return [RequestFilter.all];
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initialize() async {
    await _fetchCurrentUser();
    await fetchRequests();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        final user = await _userService.getUser(token);
        _currentUsername = user.username;
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
        _currentUsername = null;
        // Reset filter to 'all' if not authenticated
        if (_currentFilter != RequestFilter.all) {
          _currentFilter = RequestFilter.all;
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching current user: $e');
      _isAuthenticated = false;
      _currentUsername = null;
      if (_currentFilter != RequestFilter.all) {
        _currentFilter = RequestFilter.all;
      }
      notifyListeners();
    }
  }

  Future<void> fetchRequests({bool resetPage = false}) async {
    _isLoading = true;
    _error = null;
    
    if (resetPage) {
      _currentPage = 1;
    }
    
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final searchResult = await _searchService.searchRequests(
        q: _searchQuery.isEmpty ? null : _searchQuery,
        token: token,
        filter: _currentFilter,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        limit: _itemsPerPage,
        page: _currentPage,
      );
      
      _requests = searchResult.results;
      _pagination = searchResult.pagination;
      _error = null;
    } catch (e) {
      _error = 'Error loading requests: ${e.toString()}';
      print('Error fetching requests: $e');
      _requests = [];
      _pagination = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setSearchQuery(String query) async {
    if (_searchQuery != query) {
      _searchQuery = query;
      await fetchRequests(resetPage: true);
    }
  }

  Future<void> setFilter(RequestFilter filter) async {
    // Only allow authenticated filters if user is authenticated
    if (!_isAuthenticated && filter != RequestFilter.all) {
      _error = 'You need to be logged in to use this filter.';
      notifyListeners();
      return;
    }

    if (_currentFilter != filter) {
      _currentFilter = filter;
      await fetchRequests(resetPage: true);
    }
  }

  Future<void> setSorting(RequestSortBy sortBy, SortOrder sortOrder) async {
    if (_sortBy != sortBy || _sortOrder != sortOrder) {
      _sortBy = sortBy;
      _sortOrder = sortOrder;
      await fetchRequests(resetPage: true);
    }
  }

  Future<void> goToPage(int page) async {
    if (page != _currentPage && page >= 1 && (_pagination?.totalPages ?? 0) >= page) {
      _currentPage = page;
      await fetchRequests();
    }
  }

  Future<void> nextPage() async {
    if (_pagination?.hasNextPage == true) {
      await goToPage(_currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (_pagination?.hasPrevPage == true) {
      await goToPage(_currentPage - 1);
    }
  }

  Future<bool> deleteRequest(String requestId) async {
    if (!_isAuthenticated) {
      _error = 'You need to be logged in to delete requests.';
      notifyListeners();
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        _error = 'You need to be logged in to delete requests.';
        notifyListeners();
        return false;
      }

      // Use BookRequestService to delete the request
      await _bookRequestService.deleteBookRequest(token, requestId);
      
      // Remove the request from the local list
      _requests.removeWhere((request) => request.id == requestId);
      notifyListeners();
      
      // Refresh to get updated pagination
      await fetchRequests();
      
      return true;
    } catch (e) {
      _error = 'Error deleting request: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh() async {
    await fetchRequests();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool isRequestOwner(Request request) {
    return _isAuthenticated && request.username == _currentUsername;
  }

  bool canLikeRequest(Request request) {
    return _isAuthenticated && !isRequestOwner(request);
  }

  bool isRequestLikedByUser(Request request) {
    return _isAuthenticated && _currentUsername != null && request.isUpvotedBy(_currentUsername!);
  }

  Future<bool> toggleLike(String requestId) async {
    if (!_isAuthenticated) {
      _error = 'You need to be logged in to like requests.';
      notifyListeners();
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        _error = 'You need to be logged in to like requests.';
        notifyListeners();
        return false;
      }

      final upvoteResponse = await _bookRequestService.toggleUpvote(token, requestId);
      
      // Update the request in the local list
      final requestIndex = _requests.indexWhere((request) => request.id == requestId);
      if (requestIndex != -1) {
        _requests[requestIndex] = upvoteResponse.request;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = 'Error updating like: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Helper method to get display text for filters
  String getFilterDisplayText(RequestFilter filter) {
    switch (filter) {
      case RequestFilter.all:
        return 'All requests';
      case RequestFilter.mine:
        return 'My requests';
      case RequestFilter.upvoted:
        return 'Upvoted';
      case RequestFilter.notified:
        return 'Notified';
    }
  }

  // Helper method to get display text for sort options
  String getSortDisplayText(RequestSortBy sortBy) {
    switch (sortBy) {
      case RequestSortBy.date:
        return 'Date';
      case RequestSortBy.upvoters:
        return 'Upvotes';
      case RequestSortBy.peopleNotified:
        return 'People Notified';
    }
  }
}
