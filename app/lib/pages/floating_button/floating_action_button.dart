import 'package:Lino_app/pages/floating_button/dialog_options/bookbox_selection/bookbox_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../forum/add_thread_form.dart';
import '../forum/request_form.dart';

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
        backgroundColor:
            isUserAuthenticated ? Colors.blue.shade100 : Colors.grey,
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
                  onTap: () =>
                      _showRequestForm(context, widget.onRequestCreated),
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
      ),
      child: SpeedDial(
        icon: Icons.add,
        backgroundColor: Color(0xFF4AC3FF),
        children: [
          SpeedDialChild(
            backgroundColor: Colors.white,
            labelBackgroundColor: Colors.white,
            child: Icon(Icons.add),
            label: 'Add Book',
            onTap: () async {
              Get.dialog(BookBoxSelectionDialog());
              // String? scannedCode = await showDialog(
              //   context: context,
              //   builder: (context) => BookBoxSelectionDialog(),
              // );
              // if (scannedCode != null) {
              //   // Handle the scanned code, for example, navigate to another page
              //   // with the scanned UUID
              // }
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.remove),
            label: 'Remove Book',
            onTap: () async {
              showDialog(
                context: context,
                builder: (context) => Container(),
              );
            },
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
