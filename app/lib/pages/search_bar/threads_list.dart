// threads_list.dart
import 'package:flutter/material.dart';
import 'package:Lino_app/services/thread_services.dart';

class ThreadsList extends StatelessWidget {
  final String query;

  ThreadsList({required this.query});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ThreadService().searchThreads(q: query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!['threads'].isEmpty) {
          return Center(child: Text('No threads found.'));
        }

        final threads = snapshot.data!['threads'];
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: threads.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(threads[index]['title']),
              subtitle: Text(threads[index]['bookTitle']),
            );
          },
        );
      },
    );
  }
}
