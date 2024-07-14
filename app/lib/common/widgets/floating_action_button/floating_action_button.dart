import 'package:Lino_app/pages/add_book_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class LinoFloatingButton extends StatelessWidget {
  const LinoFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      children: [
        SpeedDialChild(
          child: Icon(Icons.add),
          label: 'Add Book',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBookScreen()),
          ),
        ),
        SpeedDialChild(
            child: Icon(Icons.remove),
            label: 'Remove Book',
            onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HaveNotISBNWidget()),
                )),
      ],
    );
  }
}
