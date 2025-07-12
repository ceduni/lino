import 'package:Lino_app/models/thread_model.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:Lino_app/services/thread_services.dart';

import '../forum/thread_message_screen.dart';

class ThreadsList extends StatelessWidget {
  final String query;

  ThreadsList({required this.query});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Thread>>(
      future: ThreadService().searchThreads(q: query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No threads found.'));
        }

        final threads = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: threads.length,
          itemBuilder: (context, index) {
            final thread = threads[index];
            final String timeAgo = timeago.format(thread.timestamp);

            return Card(
              color: Colors.blueGrey[50],
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: ListTile(
                leading: Image.network(thread.image ?? ''),
                title: Text(
                  thread.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.bookTitle,
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    Text(
                      'Created by ${thread.username} $timeAgo',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: 120,
                  child: Text(
                    'Messages: ${thread.messages.length}',
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ThreadMessagesScreen(threadId: thread.id, title: thread.title),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
