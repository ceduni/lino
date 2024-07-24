import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onUserIconPressed;
  final VoidCallback onMenuPressed;

  const SearchAppBar({
    required this.onUserIconPressed,
    required this.onMenuPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(80.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: SizedBox(
        height: 40,
        child: InkWell(
          onTap: () {
            showSearch(context: context, delegate: CustomSearchDelegate());
          },
          child: TextField(
            enabled: false,
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
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final List<String> searchSuggestions = [
    'Book 1',
    'Book 2',
    'Book 3',
    'Book 4',
    'Book 5',
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListView(
      children: searchSuggestions
          .where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase()))
          .map((suggestion) => ListTile(
        title: Text(suggestion),
        onTap: () {
          close(context, suggestion);
        },
      ))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: searchSuggestions
          .where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase()))
          .map((suggestion) => ListTile(
        title: Text(suggestion),
        onTap: () {
          query = suggestion;
          showResults(context);
        },
      ))
          .toList(),
    );
  }
}