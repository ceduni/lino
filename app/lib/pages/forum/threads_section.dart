import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:Lino_app/services/thread_services.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/pages/forum/thread_message_screen.dart';
import '../../services/user_services.dart';

class ThreadsSection extends StatefulWidget {
  String? query;

  ThreadsSection({super.key, this.query});

  @override
  ThreadsSectionState createState() => ThreadsSectionState();
}

class ThreadsSectionState extends State<ThreadsSection> {
  List<Card> threadCards = [];
  bool isLoading = true;
  String? currentUsername;
  String selectedOrder = 'by creation date';
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
            widget.query = null;
            fetchThreadTiles(cls: 'by creation date', asc: false);
          },
          child: const Text(
            'Reset',
            style: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          Row(
            children: [
              Text('Order: '),
              PopupMenuButton<String>(
                onSelected: (String value) {
                  setState(() {
                    selectedOrder = value;
                  });
                  fetchThreadTiles(q: widget.query, cls: selectedOrder, asc: ascending);
                },
                itemBuilder: (BuildContext context) {
                  return {'by recent activity', 'by number of messages', 'by creation date'}
                      .map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
                icon: Icon(Icons.filter_list),
              ),
              Text('Sort: '),
              PopupMenuButton<bool>(
                onSelected: (bool value) {
                  setState(() {
                    ascending = value;
                  });
                  fetchThreadTiles(q: widget.query, cls: selectedOrder, asc: ascending);
                },
                itemBuilder: (BuildContext context) {
                  return {
                    true: 'Ascending',
                    false: 'Descending',
                  }.entries.map((entry) {
                    return PopupMenuItem<bool>(
                      value: entry.key,
                      child: Text(entry.value),
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

      return Card(
        margin: EdgeInsets.symmetric(vertical: 10),
        color: isOwner ? LinoColors.accent : LinoColors.secondary,
        child: GestureDetector(
          onLongPress: isOwner
              ? () {
            _showDeleteDialog(context, thread['_id'], threadTitle);
          }
              : null,
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
              if (isOwner) {
                return await _showDeleteDialog(context, thread['_id'], threadTitle);
              }
              return false;
            },
            child: ListTile(
              leading: Image.network(thread['image']),
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

    return deleteConfirmed;
  }
}
