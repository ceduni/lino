import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:Lino_app/services/thread_services.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/pages/forum/thread_message_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/book_services.dart';
import '../../services/user_services.dart';

class ThreadsSection extends StatefulWidget {
  const ThreadsSection({super.key});

  @override
  _ThreadsSectionState createState() => _ThreadsSectionState();
}

class _ThreadsSectionState extends State<ThreadsSection> {
  List<Card> threadCards = [];
  bool isLoading = true;
  bool isUserAuthenticated = false;
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    fetchThreadTiles(cls: 'by creation date', asc: false);
    checkUser();
  }

  Future<void> fetchThreadTiles({String? q, String? cls, bool? asc, String? bookId}) async {
    try {
      final List<Card> cards = await getThreadTiles(context, q: q, cls: cls, asc: asc, bookId: bookId);
      setState(() {
        threadCards = cards;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching thread tiles: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('token');
    if (storedToken != null) {
      try {
        var us = UserService();
        final response = await us.getUser(storedToken);
        setState(() {
          isUserAuthenticated = true;
          currentUsername = response['user']['username'];
        });
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LinoColors.primary, // Set the background color of the entire section
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(10), // Add padding around the list
        children: threadCards,
      ),
    );
  }
}

Future<List<Card>> getThreadTiles(BuildContext context, {String? q, String? cls, bool? asc, String? bookId}) async {
  if (bookId != null) {
    final bs = BookService();
    final threads = await bs.getBookThreads(bookId);

    return threads.map((thread) {
      final DateTime timestamp = DateTime.parse(thread['timestamp']);
      final String timeAgo = timeago.format(timestamp);

      final threadTitle = thread['title'];
      final bookTitle = thread['bookTitle'];

      return Card(
        margin: EdgeInsets.symmetric(vertical: 10), // Add vertical margin between cards
        color: LinoColors.accent, // Set the background color of the card
        child: ListTile(
          leading: Icon(Icons.image, size: 50, color: LinoColors.accent),
          title: Text('$threadTitle : $bookTitle'),
          subtitle: Text('Thread created $timeAgo'),
          trailing: Column(
            children: [
              Icon(Icons.person),
              Text(thread['username']),
            ],
          ),
          onTap: () {
            // Navigate to the thread messages screen with the thread ID
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThreadMessagesScreen(threadId: thread['_id'], title: threadTitle),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  final ts = ThreadService();
  final r = await ts.searchThreads(q: q, cls: cls, asc: asc);
  final threads = r['threads'] as List<dynamic>;

  return threads.map((thread) {
    final DateTime timestamp = DateTime.parse(thread['timestamp']);
    final String timeAgo = timeago.format(timestamp);

    final threadTitle = thread['title'];
    final bookTitle = thread['bookTitle'];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10), // Add vertical margin between cards
      color: LinoColors.secondary, // Set the background color of the card
      child: ListTile(
        leading: Icon(Icons.image, size: 50, color: LinoColors.primary),
        title: Text('$bookTitle : $threadTitle'),
        subtitle: Text('Thread created $timeAgo'),
        trailing: Column(
          children: [
            Icon(Icons.person),
            Text(thread['username']),
          ],
        ),
        onTap: () {
          // Navigate to the thread messages screen with the thread ID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThreadMessagesScreen(threadId: thread['_id'], title: threadTitle),
            ),
          );
        },
      ),
    );
  }).toList();
}
