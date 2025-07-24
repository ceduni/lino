import 'package:flutter/material.dart';
import 'package:Lino_app/pages/profile/options/modify_profile_page.dart';
import 'package:Lino_app/pages/profile/options/favourite_genres_page.dart';
import 'package:Lino_app/pages/map/favourite_locations_page.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptionsPage extends StatefulWidget {
  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  bool _isLoading = true;
  bool _addedBookNotifications = true;
  bool _bookRequestedNotifications = true;
  String? _token;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      
      if (_token != null) {
        final user = await _userService.getUser(_token!);
        setState(() {
          _addedBookNotifications = user.notificationSettings.addedBook;
          _bookRequestedNotifications = user.notificationSettings.bookRequested;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleNotification(String type) async {
    if (_token == null) return;
    
    try {
      await _userService.toggleReceivedNotificationType(_token!, type);
      
      setState(() {
        if (type == 'addedBook') {
          _addedBookNotifications = !_addedBookNotifications;
        } else if (type == 'bookRequested') {
          _bookRequestedNotifications = !_bookRequestedNotifications;
        }
      });
    } catch (e) {
      print('Error toggling notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update notification settings')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Options'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
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
                leading: Icon(Icons.favorite, color: Colors.black),
                title: Text(
                  'Setup Favourite Genres',
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
                            FavouriteGenresPage()),
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
                leading: Icon(Icons.location_on, color: Colors.black),
                title: Text(
                  'Favourite Locations',
                  style: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.black),
                ),
                trailing:
                Icon(Icons.chevron_right, color: Colors.black),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FavouriteLocationsPage()
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Notification Settings Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notification Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: LinoColors.primary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.book_outlined, color: Colors.black),
                    title: Text(
                      'New Book Notifications',
                      style: TextStyle(
                        fontWeight: FontWeight.normal, 
                        color: Colors.black
                      ),
                    ),
                    subtitle: Text(
                      'Get notified when books matching your preferences are added to bookboxes you follow or in your favorite locations',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    trailing: Switch(
                      value: _addedBookNotifications,
                      onChanged: (value) => _toggleNotification('addedBook'),
                      activeColor: Colors.green,
                    ),
                  ),
                  Divider(height: 1, color: Colors.black26),
                  ListTile(
                    leading: Icon(Icons.request_page_outlined, color: Colors.black),
                    title: Text(
                      'Book Request Notifications',
                      style: TextStyle(
                        fontWeight: FontWeight.normal, 
                        color: Colors.black
                      ),
                    ),
                    subtitle: Text(
                      'Get notified when someone requests a book from one of the bookboxes you follow',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    trailing: Switch(
                      value: _bookRequestedNotifications,
                      onChanged: (value) => _toggleNotification('bookRequested'),
                      activeColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    ));
  }
}
