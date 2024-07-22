import 'package:flutter/material.dart';

class StatisticalWidget extends StatelessWidget {
  // Separate into 2 sections:
  // Sec 1: Personal Impact, Community Impact(2 tiles)
  // Personal Impact: Carbon savings, water saved, trees saved
  // Community Impact: Carbon savings, water saved, trees saved

  // Sec 2: Personal Preferences (3 tiles)
  // Favorite genre, nb books borrowed, nb books given

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          children: [
            GridTileWidget(
              title: 'Personal Impact',
              icon: Icons.eco,
              navigateTo: Container(),
            ),
            GridTileWidget(
              title: 'Community Impact',
              icon: Icons.people,
              navigateTo: Container(),
            ),
          ],
        ),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          children: [
            GridTileWidget(
              title: 'Books borrowed',
              icon: Icons.book,
              navigateTo: Container(),
            ),
            GridTileWidget(
              title: 'Favorite genre',
              icon: Icons.favorite,
              navigateTo: Container(),
            ),
            GridTileWidget(
              title: 'Books given',
              icon: Icons.book,
              navigateTo: Container(),
            ),
          ],
        ),
      ],
    );
  }
}

class GridTileWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget navigateTo;

  const GridTileWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.navigateTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => navigateTo),
        );
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50.0),
            SizedBox(height: 10.0),
            Text(title, style: TextStyle(fontSize: 20.0)),
          ],
        ),
      ),
    );
  }
}
