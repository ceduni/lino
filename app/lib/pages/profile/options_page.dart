import 'package:flutter/material.dart';
import 'package:Lino_app/pages/profile/options/modify_profile_page.dart';
import 'package:Lino_app/pages/profile/options/notification_keywords_page.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OptionsPage extends StatefulWidget {
  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  bool? _getAlerted;
  bool _isLoading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      final userService = UserService();
      final user = await userService.getUser(_token!);
      setState(() {
        _getAlerted = user['user']['getAlerted'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleGetAlerted(bool value) async {
    if (_token != null) {
      final userService = UserService();
      try {
        await userService.updateUser(_token!,
            getAlerted: value);
        setState(() {
          _getAlerted = value;
        });
        showToast('Alert preference updated successfully');
      } catch (e) {
        showToast('Failed to update alert preference');
        print('Failed to update alert preference: $e');
      }
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Options'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: LinoColors.primary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: Icon(Icons.person, color: Colors.black),
                title: Text(
                  'Modify Profile',
                  style: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.black),
                ),
                trailing:
                Icon(Icons.chevron_right, color: Colors.black),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ModifyProfilePage()),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: LinoColors.primary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: Icon(Icons.notifications, color: Colors.black),
                title: Text(
                  'Setup Notification Keywords',
                  style: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.black),
                ),
                trailing:
                Icon(Icons.chevron_right, color: Colors.black),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            NotificationKeywordsPage()),
                  );
                },
              ),
            ),
            SizedBox(height: 20), // Add some space before the switch
            SwitchListTile(
              activeColor: LinoColors.accent,
              title: Text('Get alerted when users make book requests?', style: TextStyle(color: Colors.black, fontSize: 14)),
              value: _getAlerted ?? false,
              onChanged: (bool value) {
                _toggleGetAlerted(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
