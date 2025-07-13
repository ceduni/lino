import '../utils/constants/api_constants.dart';
import '../models/transaction_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class TransactionServices {
  final String url = baseApiUrl;

  Future<List<Transaction>> getTransactions({
    String? username,
    String? bookTitle, 
    String? bookboxId,
    int? limit,
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
    final r = await http.get(
      Uri.parse('$url/books/transactions').replace(queryParameters: queryParameters),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final response = jsonDecode(r.body);
    if (r.statusCode != 200) {
      throw Exception('Failed to load transactions');
    }

    List<Transaction> transactions = [];
    for (var item in response['transactions']) {
      transactions.add(Transaction.fromJson(item));
    }
    return transactions;
  }

  Future<List<Transaction>> getUserTransactions(String username, {int? limit}) async {
    try {
      return await getTransactions(username: username, limit: limit);
    } catch (e) {
      print('Error fetching user transactions: $e');
      return [];
    }
  }

  Future<List<Transaction>> getBookBoxTransactions(String bookId, {int? limit}) async {
    try {
      return await getTransactions(bookboxId: bookId, limit: limit);
    } catch (e) {
      print('Error fetching book box transactions: $e');
      return [];
    }
  }
}
