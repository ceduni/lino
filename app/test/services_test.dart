import 'package:Lino_app/services/book_services.dart';
import 'package:Lino_app/services/thread_services.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final userService = UserService();
  final bookService = BookService();
  final threadService = ThreadService();
  var myToken = '';
  var qrCode = 0;
  var bb1Id = '';
  var bb2Id = '';
  var bid = '';
  var tid = '';
  var mid = '';

  await clearCollections();

  group('User authentication', () {
    test('registerUser returns a token if the user is registered', () async {
      final token = await userService.registerUser('testuser', 'test@test.com', '1234567890', 'password', true);
      expect(token, isNotNull);
      expect(token, isA<String>());
    });

    test('registerUser throws an exception when an username is already taken', () async {
      try {
        await userService.registerUser('testuser', 'test2@test.com', '1234567890', 'password', true);
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), 'Exception: Username already taken');
      }
    });

    test('registerUser throws an exception when an email is already taken', () async {
      try {
        await userService.registerUser('testuser2', 'test@test.com', '1234567890', 'password', true);
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), 'Exception: Email already taken');
      }
    });

    test('register another user', () async {
      final token = await userService.registerUser('testuser2', 'test2@test.com', '1234567890', 'password', true);
      expect(token, isNotNull);
      expect(token, isA<String>());
    });

    test('loginUser returns a token if the user is logged in', () async {
      final token = await userService.loginUser('test@test.com', 'password');
      expect(token, isNotNull);
      expect(token, isA<String>());
      myToken = token;
    });
  });

  group('Book manipulation', () {
    test('Add some bookboxes', () async {
      final bb1 = await bookService.addNewBB('BB1', 0.0, 0.0, 'BB1 info');
      expect(bb1, isNotNull);
      expect(bb1, isA<Map<String, dynamic>>());
      expect(bb1['name'], 'BB1');
      bb1Id = bb1['_id'].toString();

      final bb2 = await bookService.addNewBB('BB2', 0.1, 0.1, 'BB2 info');
      expect(bb2, isNotNull);
      expect(bb2, isA<Map<String, dynamic>>());
      expect(bb2['name'], 'BB2');
      bb2Id = bb2['_id'].toString();
    });

    test('Get info from ISBN, then add book by user', () async {
      final bookInfo = await bookService.getBookInfo('9782075023986');
      expect(bookInfo, isNotNull);
      expect(bookInfo, isA<Map<String, dynamic>>());
      expect(bookInfo['title'], 'Le cas Jack Spark (Saison 2) - Automne traqué');

      final book = await bookService.addBookToBB('b$qrCode', bb1Id, token: myToken,
          isbn: '9782075023986',
          title: bookInfo['title'],
          authors: (bookInfo['authors'] as List<dynamic>).cast<String>(),
          description: bookInfo['description'],
          coverImage: bookInfo['coverImage'],
          publisher: bookInfo['publisher'],
          parutionYear: bookInfo['parutionYear'],
          pages: bookInfo['pages'],
          categories: (bookInfo['categories'] as List<dynamic>).cast<String>()
      );
      expect(book, isNotNull);
      expect(book, isA<Map<String, dynamic>>());
      expect(book['bookId'], isA<String>());
      expect(book['books'][0], book['bookId']);
      bid = book['bookId'];
      qrCode++;
    });

    test('Get book from bookbox', () async {
      final response = await bookService.getBookFromBB(
          'b0', bb1Id, token: myToken);
      expect(response, isNotNull);
      expect(response, isA<Map<String, dynamic>>());
      expect(response['book']['title'], 'Le cas Jack Spark (Saison 2) - Automne traqué');
      expect(response['books'].length, 0);
    });

    test('Add same book in another bookbox', () async {
      final book = await bookService.addBookToBB('b0', bb2Id, token: myToken);
      expect(book, isNotNull);
      expect(book, isA<Map<String, dynamic>>());
      expect(book['bookId'], isA<String>());
      expect(book['books'].length, 1);
      expect(book['books'][0], bid);
    });
  });

  group('Thread manipulation', () {
    test('Create a thread', () async {
      final response = await threadService.createThread(myToken, bid, 'Test thread');
      expect(response, isNotNull);
      expect(response, isA<Map<String, dynamic>>());
      tid = response['threadId'].toString();
    });

    test('Add a message to the thread', () async {
      final response = await threadService.addMessage(myToken, tid, 'Test message');
      expect(response, isNotNull);
      expect(response, isA<Map<String, dynamic>>());
      mid = response['messageId'].toString();
    });

    test('Add a reaction to the message', () async {
      final reaction = await threadService.toggleMessageReaction(myToken, tid, mid, 'link/to/emoji');
      expect(reaction, isNotNull);
      expect(reaction, isA<Map<String, dynamic>>());
      expect(reaction['reaction']['reactIcon'], 'link/to/emoji');
    });
  });

  await clearCollections();
}

Future<void> clearCollections() async {
  await http.delete(Uri.parse('http://localhost:3000/users/clear'));
  await http.delete(Uri.parse('http://localhost:3000/books/clear'));
  await http.delete(Uri.parse('http://localhost:3000/threads/clear'));
  print('Collections cleared');
}