import 'dart:convert';

import 'package:Lino_app/services/book_services.dart';
import 'package:Lino_app/services/thread_services.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:test/test.dart';
import 'package:dotenv/dotenv.dart';

var env = DotEnv(includePlatformEnvironment: true)..load();

Future<void> main() async {
  final userService = UserService();
  final bookService = BookService();
  final threadService = ThreadService();

  try {
    final r1 = await bookService.searchBooks();
    final bookId = r1['books'][0]['_id'];
    print(bookId);
    final r2 = await bookService.getBookThreads(bookId);
    print(jsonEncode(r2)); // Print the result as a JSON string
    final r3 = await userService.getUser('nah');
    // print 'user : $username';
    var username = r3['username'];
    print('user : $username');
  } catch (e) {
    print('Error: $e');
  }
}
