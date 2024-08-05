import 'package:flutter/material.dart';
import 'package:Lino_app/pages/profile/options/modify_profile_page.dart';
import 'package:Lino_app/utils/constants/colors.dart';

class OptionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Options'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: LinoColors.primary, // Light blue background
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
          child: ListTile(
            leading: Icon(Icons.person, color: Colors.black), // User icon on the left
            title: Text(
              'Modify Profile',
              style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black), // Text styling
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.black), // ">" button on the right
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ModifyProfilePage()),
              );
            },
          ),
        ),
      ),
    );
  }
}
