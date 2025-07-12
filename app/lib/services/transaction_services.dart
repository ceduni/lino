import '../utils/constants/api_constants.dart';
import '../models/transaction_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class TransactionServices {
  final String url = baseApiUrl;

  Future<Map<String, dynamic>> getTransactions({
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
    final response = await http.get(
      Uri.parse('$url/books/transactions').replace(queryParameters: queryParameters),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load transactions');
    }

    return response.body.isNotEmpty ? jsonDecode(response.body) : {};
  }

  Future<Map<String, dynamic>> getUserTransactions(String username, {int? limit}) async {
    return await getTransactions(username: username, limit: limit);
  }

  Future<List<Transaction>> getUserTransactionsList(String username, {int? limit}) async {
    try {
      final response = await getUserTransactions(username, limit: limit);
      if (response['transactions'] != null) {
        List<dynamic> transactionData = response['transactions'];
        return transactionData.map((json) => Transaction.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user transactions: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getBookBoxTransactions(String bookId, {int? limit}) async {
    return await getTransactions(bookboxId: bookId, limit: limit);
  }
}
