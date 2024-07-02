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
  var bbids = ['',''];
  var sbl = 0;

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

    test('register a bunch of other users', () async {
      for (var i = 2; i < 7; i++) {
        final token = await userService.registerUser('testuser$i', 'test$i@test.com', '1234567890', 'password', true);
        expect(token, isNotNull);
        expect(token, isA<String>());
      }
    });

    test('try to update an user with an already taken username', () async {
      final token = await userService.loginUser('testuser2', 'password');
      try {
        await userService.updateUser(token, username: 'testuser');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), 'Exception: Username already taken');
      }
    });

    test('Update some users with notification key words', () async {
      for (var i in [3, 5]) {
        final token = await userService.loginUser('testuser$i', 'password');
        final user = await userService.updateUser(token, keyWords: 'Victor,Dixen');
        expect(user, isNotNull);
        expect(user, isA<Map<String, dynamic>>());
        expect(user['user']['notificationKeyWords'], ['Victor', 'Dixen']);
      }
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
      bbids[0] = bb1Id;

      final bb2 = await bookService.addNewBB('BB2', 0.1, 0.1, 'BB2 info');
      expect(bb2, isNotNull);
      expect(bb2, isA<Map<String, dynamic>>());
      expect(bb2['name'], 'BB2');
      bb2Id = bb2['_id'].toString();
      bbids[1] = bb2Id;
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

      final user = await userService.getUser(myToken);
      expect(user, isNotNull);
      expect(user, isA<Map<String, dynamic>>());
      expect(user['user']['ecologicalImpact']['savedWater'], 2000);
    });

    test('Add newly added book to a user\'s favorite books', () async {
      final favorites = await userService.addToFavorites(myToken, bid);
      expect(favorites, isNotNull);
      expect(favorites, isA<List<String>>());
      expect(favorites.length, 1);
      expect(favorites[0], bid);
    });

    test('See if a notification has been sent to users with the correct notification key words', () async {
      for (var i = 3; i < 7; i++) {
        final token = await userService.loginUser('testuser$i', 'password');
        final user = await userService.getUser(token);
        expect(user, isNotNull);
        expect(user, isA<Map<String, dynamic>>());
        if (i == 3 || i == 5) {
          expect(user['user']['notifications'].length, 1);
          expect(user['user']['notifications'][user['user']['notifications'].length-1]['content'], 'The book "Le cas Jack Spark (Saison 2) - Automne traqué" has been added to the bookbox "BB1" !');
        } else {
          expect(user['user']['notifications'].length, 0);
        }
      }
    });

    test('Get book from bookbox', () async {
      final response = await bookService.getBookFromBB(
          'b0', bb1Id, token: myToken);
      expect(response, isNotNull);
      expect(response, isA<Map<String, dynamic>>());
      expect(response['book']['title'], 'Le cas Jack Spark (Saison 2) - Automne traqué');
      expect(response['books'].length, 0);
    });

    test('Check if a notification was sent to the users having this book as one of their favorites', () async {
      final user = await userService.getUser(myToken);
      expect(user, isNotNull);
      expect(user, isA<Map<String, dynamic>>());
      expect(user['user']['notifications'].length, 1);
      expect(user['user']['notifications'][0]['content'], 'The book "Le cas Jack Spark (Saison 2) - Automne traqué" has been removed from the bookbox "BB1" !');
    });

    test('Add same book in another bookbox', () async {
      final book = await bookService.addBookToBB('b0', bb2Id, token: myToken);
      expect(book, isNotNull);
      expect(book, isA<Map<String, dynamic>>());
      expect(book['bookId'], isA<String>());
      expect(book['books'].length, 1);
      expect(book['books'][0], bid);
    });

    test('Add a bunch of books', () async {
      final isbns = [
        '9782075020893',
        '9781781101070',
        '9781781105542',
        '9781421581514',
        '9781421545257',
        '9782331009501',
        '9781421544328',
        '9781975319441',
        '9781974720286'
      ];

      for (int i = 0; i<isbns.length; i++) {
        final bookInfo = await bookService.getBookInfo(isbns[i]);
        final book = await bookService.addBookToBB('b$qrCode', bbids[i%2], token: myToken,
            isbn: isbns[i],
            title: bookInfo['title'],
            authors: bookInfo['authors'] != null ? (bookInfo['authors'] as List<dynamic>).cast<String>() : <String>[],
            description: bookInfo['description'],
            coverImage: bookInfo['coverImage'],
            publisher: bookInfo['publisher'],
            parutionYear: bookInfo['parutionYear'],
            pages: bookInfo['pages'],
            categories: bookInfo['categories'] != null ? (bookInfo['categories'] as List<dynamic>).cast<String>() : <String>[]
        );
        expect(book, isNotNull);
        expect(book, isA<Map<String, dynamic>>());
        expect(book['bookId'], isA<String>());
        expect(book['books'][book['books'].length-1], book['bookId']);
        qrCode++;
      }
    });

    test('Search specific books in specific order : '
        'in a specific book box, in the ascending alphabetical order of the 1st author\'s name', () async {
      final response = await bookService.searchBooks(cls: 'by author', asc: true, bbid: bb1Id);
      expect(response, isNotNull);
      expect(response, isA<Map<String, dynamic>>());
      for (var i = 0; i < response['books'].length - 1; i++) {
        expect(response['books'][i]['authors'][0].compareTo(response['books'][i + 1]['authors'][0]), lessThanOrEqualTo(0));
      }
      sbl = response['books'].length;
    });

    test('Remove a book from the bookbox then expect the result to have 1 book less', () async {
      final response = await bookService.getBookFromBB('b1', bb1Id, token: myToken);
      final response2 = await bookService.searchBooks(cls: 'by author', asc: true, bbid: bb1Id);
      expect(response, isNotNull);
      expect(response2['books'].length, sbl-1);
    });

    test('Same as earlier but in descending order', () async {
      final response = await bookService.searchBooks(cls: 'by author', asc: false, bbid: bb1Id);
      expect(response, isNotNull);
      expect(response, isA<Map<String, dynamic>>());
      for (var i = 0; i < response['books'].length - 1; i++) {
        expect(response['books'][i]['authors'][0].compareTo(response['books'][i + 1]['authors'][0]), greaterThanOrEqualTo(0));
      }
    });

    test('Search specific books in specific order : '
        'published after 2016, in the ascending alphabetical order of the title', () async {
      final response = await bookService.searchBooks(cls: 'by title', asc: true, bf: false, py: 2016);
      expect(response, isNotNull);
      expect(response, isA<Map<String, dynamic>>());
      for (var i = 0; i < response['books'].length - 1; i++) {
        expect(response['books'][i]['title'].compareTo(response['books'][i + 1]['title']), lessThanOrEqualTo(0));
      }
    });

    test('Search specific books in specific order : '
        'whose title or author contains "Harry", in the descending order of the parution year', () async {
      final response = await bookService.searchBooks(cls: 'by year', asc: false, kw: 'Harry');
      expect(response, isNotNull);
      expect(response, isA<Map<String, dynamic>>());
      for (var i = 0; i < response['books'].length - 1; i++) {
        expect(response['books'][i]['title'].contains('Harry') || response['books'][i]['authors'].contains('Harry'), true);
        expect(response['books'][i]['parutionYear'].compareTo(response['books'][i + 1]['parutionYear']), greaterThanOrEqualTo(0));
      }
    });

    test('Search specific books in specific order : '
        'whose publisher is VIZ Media LLC, in the ascending order of the most recent activity', () async {
      final response = await bookService.searchBooks(pub: 'VIZ Media LLC', cls: 'by most recent activity', asc: true);
      expect(response, isNotNull);
      expect(response, isA<Map<String, dynamic>>());
      for (var i = 0; i < response['books'].length - 1; i++) {
        expect(response['books'][i]['publisher'], 'VIZ Media LLC');
        final date1 = DateTime.parse(response['books'][i]['dateLastAction']);
        final date2 = DateTime.parse(response['books'][i + 1]['dateLastAction']);
        expect(date1.isBefore(date2), true);
      }
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

    test('Add a message that responds to another message', () async {
      final response = await threadService.addMessage(myToken, tid, 'Test response', respondsTo: mid);
      expect(response, isNotNull);
      expect(response, isA<Map<String, dynamic>>());
      final thread = await threadService.getThread(tid);
      expect(thread, isNotNull);
      expect(thread, isA<Map<String, dynamic>>());
      expect(thread['messages'].length, 2);
      expect(thread['messages'][1]['respondsTo'], mid);
    });

    test('Add a reaction to the message', () async {
      final reaction = await threadService.toggleMessageReaction(myToken, tid, mid, 'link/to/emoji');
      expect(reaction, isNotNull);
      expect(reaction, isA<Map<String, dynamic>>());
      expect(reaction['reaction']['reactIcon'], 'link/to/emoji');
    });

    test('Search a thread', () async {
      final response = await threadService.searchThreads(q: 'Test');
      expect(response, isNotNull);
      expect(response, isA<Map<String, dynamic>>());
      expect(response['threads'].length, 1);
      expect(response['threads'][0]['title'], 'Test thread');
    });

    test('Search an inexistent thread', () async {
      final response = await threadService.searchThreads(q: 'Inexistent');
      expect(response, isNotNull);
      expect(response, isA<Map<String, dynamic>>());
      expect(response['threads'].length, 0);
    });
  });

}

Future<void> clearCollections() async {
  await http.delete(Uri.parse('http://localhost:3000/users/clear'));
  await http.delete(Uri.parse('http://localhost:3000/books/clear'));
  await http.delete(Uri.parse('http://localhost:3000/threads/clear'));
  print('Collections cleared');
}