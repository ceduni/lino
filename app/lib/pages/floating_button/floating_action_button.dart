import 'package:Lino_app/pages/floating_button/add_book_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../forum/add_thread_form.dart';
import '../forum/requests_section.dart';

class LinoFloatingButton extends StatefulWidget {
  final int selectedIndex;

  const LinoFloatingButton({required this.selectedIndex, Key? key}) : super(key: key);

  @override
  _LinoFloatingButtonState createState() => _LinoFloatingButtonState();
}

class _LinoFloatingButtonState extends State<LinoFloatingButton> {
  bool isUserAuthenticated = false;

  @override
  void initState() {
    super.initState();
    checkUserAuthentication();
  }

  Future<void> checkUserAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      isUserAuthenticated = token != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedIndex == 2) {
      // Forum page is active
      return SpeedDial(
        icon: Icons.add,
        backgroundColor: isUserAuthenticated ? Colors.blue.shade100 : Colors.grey,
        children: isUserAuthenticated
            ? [
          SpeedDialChild(
            backgroundColor: Colors.blue.shade300,
            labelBackgroundColor: Colors.blue.shade300,
            child: Icon(Icons.add),
            label: 'Add Thread',
            onTap: () => _addThread(context),
          ),
          SpeedDialChild(
            backgroundColor: Colors.blue.shade300,
            labelBackgroundColor: Colors.blue.shade300,
            child: Icon(Icons.add),
            label: 'Add Request',
            onTap: () => _showRequestForm(context),
          ),
        ]
            : [],
      );
    }

    // Default Floating Button
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
            MaterialPageRoute(builder: (context) => RemoveBookScreen()),
          ),
        ),
      ],
    );
  }

  void _addThread(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: AddThreadForm(),
        );
      },
    );
  }

  void _showRequestForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: RequestForm(),
        );
      },
    );
  }
}