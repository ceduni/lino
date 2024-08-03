import 'dart:convert';

import 'package:Lino_app/services/book_services.dart';
import 'package:Lino_app/services/thread_services.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:dotenv/dotenv.dart';

var env = DotEnv(includePlatformEnvironment: true)..load();

Future<void> main() async {
  final userService = UserService();
  final bookService = BookService();

  try {
    final r1 = await bookService.searchBooks();
    final bookId = r1['books'][0]['_id'];
    print(bookId);
    final r4 = await bookService.searchBookboxes();
    print(jsonEncode(r4));
  } catch (e) {
    print('Error: $e');
  }
}
