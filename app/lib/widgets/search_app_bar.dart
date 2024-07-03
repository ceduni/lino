import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onUserIconPressed;
  final VoidCallback onMenuPressed;
  final ValueChanged<String> onSearchChanged;

  SearchAppBar({
    required this.onUserIconPressed,
    required this.onMenuPressed,
    required this.onSearchChanged,
  });

  @override
  Size get preferredSize => Size.fromHeight(110.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.account_circle,
            color: Color.fromARGB(255, 176, 188, 234), size: 43.0),
        onPressed: onUserIconPressed,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.menu,
              color: Color.fromARGB(255, 176, 188, 234), size: 43.0),
          onPressed: onMenuPressed,
        ),
      ],
      flexibleSpace: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                    labelStyle: TextStyle(fontSize: 16.0),
                    //TODO : Change font style, bug here for some reason
                    hintText: 'Rechercher...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color.fromARGB(255, 226, 236, 240)),
              ),
            ),
            SizedBox(),
          ],
        ),
      ),
    );
  }
}
