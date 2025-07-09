import 'package:Lino_app/pages/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_services.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/api_constants.dart';
import '../search_bar/search_bar.dart';
import 'notifications_page.dart';
import 'package:Lino_app/services/websocket_service.dart';

class LinoAppBar extends StatefulWidget implements PreferredSizeWidget {
  final int sourcePage;

  const LinoAppBar({required this.sourcePage});

  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  _LinoAppBarState createState() => _LinoAppBarState();
}

class _LinoAppBarState extends State<LinoAppBar> {
  late Future<bool> _isUserLoggedInFuture;
  WebSocketService webSocketService = WebSocketService();
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _isUserLoggedInFuture = _isUserLoggedIn();
    _fetchUnreadCount();
  }

  Future<bool> _isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return false;
    try {
      final userService = UserService();
      final user = await userService.getUser(token);
      if (user['user'] != null) {
        // Initialize WebSocket connection here
        webSocketService.connect(
          webSocketUrl,
          userId: user['user']['_id'],
          onEvent: (event, data) async {
            if (event == 'newNotification') {
              await _fetchAndUpdateUnreadCount();
            }
          },
        );

        return true;
      }
      return false;
    } catch (e) {
      print('Error: $e'); // Debug statement
      return false;
    }
  }

  Future<void> _fetchAndUpdateUnreadCount() async {
    final newUnreadCount = await _fetchUnreadCount();
    setState(() {
      unreadCount = newUnreadCount;
    });
  }

  Future<int> _fetchUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      print('No token found'); // Debug statement
      return 0;
    }
    try {
      final userService = UserService();
      final notifications = await userService.getUserNotifications(token);
      final count = notifications.where((n) => !n['read']).length;
      print('Unread count from service: $count'); // Debug statement
      return count;
    } catch (e) {
      print('Error fetching unread count: $e'); // Debug statement
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserLoggedInFuture,
      builder: (context, snapshot) {
        bool isLoggedIn = snapshot.data ?? false;

        return AppBar(
          backgroundColor: LinoColors.accent,
          flexibleSpace: Padding(
            padding: EdgeInsets.only(top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      if (!isLoggedIn) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ),
                        );
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLoggedIn ? Icons.person : Icons.login,
                          color: isLoggedIn ? Colors.white : Colors.red,
                        ),
                        SizedBox(height: 2), // Minimal space between icon and text
                        Text(
                          isLoggedIn ? 'Profile' : 'Log In',
                          style: isLoggedIn ? TextStyle(color: Colors.white) : TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: LinoSearchBar(sourcePage: widget.sourcePage),
                  ),
                ),
                if (isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications, color: Colors.white,),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => NotificationsPage(),
                              ),
                            );
                            // Refresh the unread count when returning from the notifications page
                            _fetchAndUpdateUnreadCount();
                          },
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 11,
                            top: 11,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Text(
                                '$unreadCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    webSocketService.disconnect();
    super.dispose();
  }
}
