import 'package:Lino_app/pages/thread_message_screen.dart';
import 'package:Lino_app/services/thread_services.dart';
import 'package:flutter/material.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../services/book_services.dart';


class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: LinoColors.primary,
          title: const Text('Forum'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Threads'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ThreadsSection(),
            RequestsSection(),
          ],
        ),
      ),
    );
  }
}

class ThreadsSection extends StatefulWidget {
  const ThreadsSection({super.key});

  @override
  _ThreadsSectionState createState() => _ThreadsSectionState();
}

class _ThreadsSectionState extends State<ThreadsSection> {
  List<Card> threadCards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchThreadTiles();
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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView(
      children: threadCards,
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
              builder: (context) => ThreadMessagesScreen(threadId: thread['_id'], title: threadTitle,),
            ),
          );
        },
      ),
    );
  }).toList();
}


class RequestsSection extends StatelessWidget {
  const RequestsSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Requests Section'),
    );
  }
}


