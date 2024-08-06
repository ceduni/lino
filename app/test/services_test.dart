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
    final token = await userService.loginUser('Asp3rity', '1234');
    print('Token: $token');
    await bookService.
    addBookToBB(
        'sbdajdnkandkjfdsfds',
        '66aad11b0a2f27e307af962e',
        token: token,
        isbn: '978-3-16-148410-0',
        title: 'The Art of War',
        authors: ['Sun Tzu'],
        description: 'A book on military strategy',
        coverImage: 'https://example.com/image.jpg',
        publisher: 'Penguin Classics',
        parutionYear: 500,
        pages: 100,
        categories: ['Military', 'Strategy'],
    );
  } catch (e) {
    print('Error: $e');
  }
}