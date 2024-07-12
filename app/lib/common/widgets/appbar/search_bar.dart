import 'package:flutter/material.dart';

class LinoSearchBar extends StatelessWidget {
  const LinoSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
