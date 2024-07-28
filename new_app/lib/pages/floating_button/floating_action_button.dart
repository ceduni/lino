import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../forum/add_thread_form.dart';
import '../forum/request_form.dart';
import 'add_book_screen.dart';
import 'dialog_options/scan_qr_code.dart';

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
    return Container(
      margin: EdgeInsets.all(16.0), // Adjust margin as needed
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color.fromRGBO(214, 142, 97, 1), // Border color
          width: 3.0, // Border width
        ),
      ),
      child: SpeedDial(
        icon: Icons.add,
        backgroundColor: Colors.blue.shade800,
        children: [
          SpeedDialChild(
            backgroundColor: Colors.white,
            labelBackgroundColor: Colors.white,
            child: Icon(Icons.add),
            label: 'Add Book',
            onTap: () async {
              String? scannedCode = await showDialog(
                context: context,
                builder: (context) => ScanQRCode(),
              );
              if (scannedCode != null) {
                // Handle the scanned code, for example, navigate to another page
                // with the scanned UUID
              }
            },
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
      ),
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
