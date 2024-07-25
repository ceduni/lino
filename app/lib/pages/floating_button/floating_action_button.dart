import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../forum/add_thread_form.dart';
import '../forum/request_form.dart';
import 'add_book_screen.dart';
import 'add_book_dialog.dart';

class LinoFloatingButton extends StatefulWidget {
  final int selectedIndex;
  final VoidCallback? onThreadCreated;
  final VoidCallback? onRequestCreated;

  const LinoFloatingButton({
    required this.selectedIndex,
    this.onThreadCreated,
    this.onRequestCreated,
    Key? key,
  }) : super(key: key);

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
            onTap: () => _addThread(context, widget.onThreadCreated),
          ),
          SpeedDialChild(
            backgroundColor: Colors.blue.shade300,
            labelBackgroundColor: Colors.blue.shade300,
            child: Icon(Icons.add),
            label: 'Add Request',
            onTap: () => _showRequestForm(context, widget.onRequestCreated),
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
          onTap: () => showDialog(
            context: context,
            builder: (context) => AddBookDialog(),
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

  void _addThread(BuildContext context, VoidCallback? onThreadCreated) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: AddThreadForm(onThreadCreated: onThreadCreated!),
        );
      },
    );
  }

  void _showRequestForm(BuildContext context, VoidCallback? onRequestCreated) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: RequestForm(onRequestCreated: onRequestCreated!),
        );
      },
    );
  }
}
