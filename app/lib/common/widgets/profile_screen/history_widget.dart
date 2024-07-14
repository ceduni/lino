import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/utils/constants/default_placeholder.dart';
import 'package:Lino_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class HistoryWidget extends StatelessWidget {
  final List<Book> books;

  const HistoryWidget({required this.books});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: LinoSizes.gridViewSpacing,
        mainAxisSpacing: LinoSizes.gridViewSpacing,
        childAspectRatio: 0.7,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return BookGridContainer(
          imagePath: books[index].coverImage ?? LinoDefaults.coverImage,
          title: books[index].title,
          date: books[index].dateLastAction,
        );
      },
    );
  }
}

class BookGridContainer extends StatelessWidget {
  final String imagePath;
  final String title;
  final DateTime date;

  const BookGridContainer(
      {required this.imagePath, required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Image.asset(imagePath), Text(title), Text(date.toString())],
    );
  }
}
