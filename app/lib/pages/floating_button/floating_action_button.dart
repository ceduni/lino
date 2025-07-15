import 'package:Lino_app/pages/floating_button/dialog_options/bookbox_selection/bookbox_selection_dialog.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../forum/add_thread_form.dart'; // Commented out - threads functionality removed
import '../forum/request_form.dart';

class LinoFloatingButton extends StatefulWidget {
  final int selectedIndex;
  // final VoidCallback? onThreadCreated; // Commented out - threads functionality removed
  final VoidCallback? onRequestCreated;

  const LinoFloatingButton({
    required this.selectedIndex,
    // this.onThreadCreated, // Commented out - threads functionality removed
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
      // Requests page is active - Direct "Create Request" button
      return Container(
        margin: EdgeInsets.all(16.0), // Same margin as default floating button
        child: FloatingActionButton.extended(
          onPressed: isUserAuthenticated 
              ? () => _showRequestForm(context, widget.onRequestCreated)
              : null,
          backgroundColor: isUserAuthenticated ? LinoColors.secondary : Colors.grey,
          elevation: 2.0,
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            'Create Request',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
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
              Get.dialog(BookBoxSelectionDialog(isAddBook: true));
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.remove),
            label: 'Remove Book',
            onTap: () async {
              Get.dialog(BookBoxSelectionDialog(isAddBook: false));
            },
          ),
        ],
      ),
    );
  }

  // void _addThread(BuildContext context, VoidCallback? onThreadCreated) { // Commented out - threads functionality removed
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (context) {
  //       return Padding(
  //         padding: MediaQuery.of(context).viewInsets,
  //         child: AddThreadForm(onThreadCreated: onThreadCreated!),
  //       );
  //     },
  //   );
  // }

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
