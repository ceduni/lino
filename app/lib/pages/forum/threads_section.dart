import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:Lino_app/services/thread_services.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/pages/forum/thread_message_screen.dart';
import '../../services/user_services.dart';

class ThreadsSection extends StatefulWidget {
  final String? query;

  const ThreadsSection({super.key, this.query});

  @override
  ThreadsSectionState createState() => ThreadsSectionState();
}

class ThreadsSectionState extends State<ThreadsSection> {
  List<Card> threadCards = [];
  bool isLoading = true;
  String? currentUsername;
  String selectedOrder = 'by recent activity';
  bool ascending = false;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
    fetchThreadTiles(q: widget.query, cls: selectedOrder, asc: ascending);
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

  Future<void> fetchThreadTiles({String? q, String? cls, bool? asc}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final List<Card> cards = await getThreadTiles(context, q: q, cls: cls, asc: asc);
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
    return Scaffold(
      backgroundColor: LinoColors.primary,
      appBar: AppBar(
        title: ElevatedButton(
          onPressed: () {
            fetchThreadTiles(cls: 'by recent activity', asc: false);
          },
          child: const Text(
            'Reset',
            style: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          Row(
            children: [
              Text('Sort: '),
              PopupMenuButton<String>(
                onSelected: (String value) {
                  setState(() {
                    switch (value) {
                      case 'with most recent activity':
                        selectedOrder = 'by recent activity';
                        ascending = false;
                        break;
                      case 'created most recently':
                        selectedOrder = 'by creation date';
                        ascending = false;
                        break;
                      case 'with the most number of messages':
                        selectedOrder = 'by number of messages';
                        ascending = false;
                        break;
                    }
                  });
                  fetchThreadTiles(q: widget.query, cls: selectedOrder, asc: ascending);
                },
                itemBuilder: (BuildContext context) {
                  return {
                    'with most recent activity',
                    'created most recently',
                    'with the most number of messages',
                  }.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
                icon: Icon(Icons.sort),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(10),
        children: threadCards,
      ),
    );
  }

  Future<List<Card>> getThreadTiles(BuildContext context, {String? q, String? cls, bool? asc}) async {
    final ts = ThreadService();
    final r = await ts.searchThreads(q: q, cls: cls, asc: asc);
    final threads = r['threads'] as List<dynamic>;

    return threads.map((thread) {
      final DateTime timestamp = DateTime.parse(thread['timestamp']);
      final String timeAgo = timeago.format(timestamp);

      final threadTitle = thread['title'];
      final bookTitle = thread['bookTitle'];
      final isOwner = thread['username'] == currentUsername;

      if (isOwner) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          color: LinoColors.accent,
          child: GestureDetector(
            onLongPress: () {
              _showDeleteDialog(context, thread['_id'], threadTitle);
            },
            child: Dismissible(
              key: Key(thread['_id']),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await _showDeleteDialog(context, thread['_id'], threadTitle);
              },
              child: ListTile(
                leading: _buildBookCover(thread['image'], bookTitle),
                title: Text('$bookTitle : $threadTitle'),
                subtitle: Text('Thread created $timeAgo'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person),
                    Text(thread['username']),
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
            ),
          ),
        );
      } else {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          color: LinoColors.secondary,
          child: ListTile(
            leading: _buildBookCover(thread['image'], bookTitle),
            title: Text('$bookTitle : $threadTitle'),
            subtitle: Text('Thread created $timeAgo'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person),
                Text(thread['username']),
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
      }
    }).toList();
  }

  Future<bool> _showDeleteDialog(BuildContext context, String threadId, String threadTitle) async {
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
          await ThreadService().deleteThread(token, threadId);
          fetchThreadTiles(cls: 'by recent activity', asc: false); // Re-fetch threads
          showToast('Thread deleted successfully!');
        } catch (e) {
          showToast('Error: ${e.toString()}');
        }
      }
    }

    return deleteConfirmed;
  }

  Widget _buildBookCover(String? imageUrl, String bookTitle) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
          return _buildDefaultCover(bookTitle);
        },
      );
    } else {
      return _buildDefaultCover(bookTitle);
    }
  }

  Widget _buildDefaultCover(String bookTitle) {
    return Container(
      width: 56,
      height: 56,
      color: Colors.grey,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            bookTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
