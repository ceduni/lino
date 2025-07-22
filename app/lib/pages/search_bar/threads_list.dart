import 'package:Lino_app/models/search_model.dart';
import 'package:Lino_app/models/thread_model.dart';
import 'package:Lino_app/services/search_services.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../forum/threads/thread_message_screen.dart';

class ThreadsList extends StatelessWidget {
  final String query;

  ThreadsList({required this.query});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SearchModel<Thread>>(
      future: SearchService().searchThreads(q: query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
          return Center(child: Text('No threads found.'));
        }

        final threads = snapshot.data!.results;
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
