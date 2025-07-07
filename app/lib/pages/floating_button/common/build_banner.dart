import 'package:flutter/material.dart';

Widget buildBanner(BuildContext context, String title) {
  return Container(
    color: Color.fromARGB(160, 10, 79, 135),
    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    child: Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}
