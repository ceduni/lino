import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:Lino_app/services/thread_services.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/pages/forum/thread_message_screen.dart';
import '../../services/book_services.dart';
import '../../services/user_services.dart';

class ThreadsSection extends StatefulWidget {
  const ThreadsSection({super.key});

  @override
  ThreadsSectionState createState() => ThreadsSectionState();
}

class ThreadsSectionState extends State<ThreadsSection> {
  List<Card> threadCards = [];
  bool isLoading = true;
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
    fetchThreadTiles(cls: 'by creation date', asc: false);
  }

  Future<void> fetchCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final user = await UserService().getUser(token);
      setState(() {
        currentUsername = user['user']['username'];
      });
    }
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
    return Container(
      color: LinoColors.primary,
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(10),
        children: threadCards,
      ),
    );
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
        final isOwner = thread['username'] == currentUsername;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          color: isOwner ? LinoColors.accent : LinoColors.secondary,
          child: ListTile(
            leading: Icon(Icons.image, size: 50, color: LinoColors.accent),
            title: Text('$threadTitle : $bookTitle'),
            subtitle: Text('Thread created $timeAgo'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person),
                Text(thread['username']),
                if (isOwner)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, shadows: const [
                      BoxShadow(color: Colors.black, blurRadius: 1),
                    ]),
                    onPressed: () async {
                      final deleteConfirmed = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete thread "$threadTitle"?'),
                          content: Text('All the messages written in it will be deleted.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (deleteConfirmed == true) {
                        final prefs = await SharedPreferences.getInstance();
                        final token = prefs.getString('token');
                        if (token != null) {
                          try {
                            await ThreadService().deleteThread(token, thread['_id']);
                            fetchThreadTiles(cls: 'by creation date', asc: false); // Re-fetch threads
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Thread deleted successfully!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        }
                      }
                    },
                  ),
              ],
            ),
            onTap: () {
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
      final isOwner = thread['username'] == currentUsername;

      return Card(
        margin: EdgeInsets.symmetric(vertical: 10),
        color: isOwner ? LinoColors.accent : LinoColors.secondary,
        child: ListTile(
          leading: Icon(Icons.image, size: 50, color: LinoColors.primary),
          title: Text('$bookTitle : $threadTitle'),
          subtitle: Text('Thread created $timeAgo'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person),
              Text(thread['username']),
              if (isOwner)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, shadows: const [
                    BoxShadow(color: Colors.black, blurRadius: 1),
                  ]),
                  onPressed: () async {
                    final deleteConfirmed = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete thread $threadTitle?'),
                        content: Text('All the messages written in it will be deleted.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (deleteConfirmed == true) {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('token');
                      if (token != null) {
                        try {
                          await ThreadService().deleteThread(token, thread['_id']);
                          fetchThreadTiles(cls: 'by creation date', asc: false); // Re-fetch threads
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Thread deleted successfully!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      }
                    }
                  },
                ),
            ],
          ),
          onTap: () {
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
}
