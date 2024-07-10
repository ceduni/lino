import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onUserIconPressed;
  final VoidCallback onMenuPressed;
  final ValueChanged<String> onSearchChanged;

  const SearchAppBar({
    required this.onUserIconPressed,
    required this.onMenuPressed,
    required this.onSearchChanged,
  });

  @override
  Size get preferredSize => Size.fromHeight(80.0); // Reduced height for better UI

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Container(
        height: 40,
        child: TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}

