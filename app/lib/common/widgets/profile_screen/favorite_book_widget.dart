import 'package:Lino_app/common/widgets/profile_screen/history_widget.dart';
import 'package:Lino_app/models/book_model.dart';
import 'package:Lino_app/utils/constants/default_placeholder.dart';
import 'package:Lino_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

// TODO: Maybe inherit from a common class with HistoryWidget to avoid repetition

class FavoriteBookWidget extends StatelessWidget {
  final List<Book> favoriteBooks;

  const FavoriteBookWidget({super.key, required this.favoriteBooks});

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
      itemCount: favoriteBooks.length,
      itemBuilder: (context, index) {
        return BookGridContainer(
          imagePath: favoriteBooks[index].coverImage ?? LinoDefaults.coverImage,
          title: favoriteBooks[index].title,
          date: favoriteBooks[index].dateLastAction,
        );
      },
    );
  }
}
