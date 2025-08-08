import 'package:Lino_app/models/search_model.dart';

import '../utils/constants/api_constants.dart';
import '../models/transaction_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class TransactionServices {
  final String url = baseApiUrl;

  Future<SearchModel<Transaction>> searchTransactions({
    String? username,
    String? bookTitle, 
    String? bookboxId,
    int? limit,
    int? page,
  }) async {
    // Make a GET request to the server
    // Send the token to the server
    // If the server returns a 200 status code, the transactions are returned
    // If the server returns another status code, an error is thrown
    final queryParameters = <String, String>{};
    if (username != null) queryParameters['username'] = username;
    if (bookTitle != null) queryParameters['bookTitle'] = bookTitle;
    if (bookboxId != null) queryParameters['bookboxId'] = bookboxId;
    if (limit != null) queryParameters['limit'] = limit.toString();
    if (page != null) queryParameters['page'] = page.toString();
    final r = await http.get(
      Uri.parse('$url/search/transactions').replace(queryParameters: queryParameters),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception('Failed to load transactions');
    }

    return SearchModel<Transaction>.fromJson(
      response,
      'transactions',
      Transaction.fromJson,
    );
  }

  Future<SearchModel<Transaction>> getUserTransactions(String username, {int? limit}) async {
    try {
      return await searchTransactions(username: username, limit: limit);
    } catch (e) {
      print('Error fetching user transactions: $e');
      rethrow;
    }
  }

  Future<SearchModel<Transaction>> getBookBoxTransactions(String bookboxId, {int? limit}) async {
    try {
      return await searchTransactions(bookboxId: bookboxId, limit: limit);
    } catch (e) {
      print('Error fetching book box transactions: $e');
      rethrow;
    }
  }
}
