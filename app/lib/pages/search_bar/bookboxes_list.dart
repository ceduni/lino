// bookboxes_list.dart
import 'package:flutter/material.dart';
import 'package:Lino_app/services/book_services.dart';

class BookBoxesList extends StatelessWidget {
  final String query;

  BookBoxesList({required this.query});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: BookService().searchBookboxes(kw: query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!['bookboxes'].isEmpty) {
          return Center(child: Text('No bookboxes found.'));
        }

        final bookboxes = snapshot.data!['bookboxes'];
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: bookboxes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(bookboxes[index]['name']),
              subtitle: Text(
                bookboxes[index]['infoText'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        );
      },
    );
  }
}
