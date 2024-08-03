import 'package:flutter/material.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:Lino_app/utils/constants/colors.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<dynamic>> _notificationsFuture;
  late String _token;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchNotifications();
  }

  Future<List<dynamic>> _fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token')!;
    final userService = UserService();
    final response = await userService.getUserNotifications(_token);
    return response['notifications'];
  }

  Future<void> _markAsRead(String id) async {
    final userService = UserService();
    await userService.markNotificationAsRead(_token, id);
    setState(() {
      _notificationsFuture = _fetchNotifications();
    });
  }

  Future<void> _markAllAsRead() async {
    final userService = UserService();
    final notifications = await _notificationsFuture;
    for (var notification in notifications) {
      if (!notification['read']) {
        await userService.markNotificationAsRead(_token, notification['_id']);
      }
    }
    setState(() {
      _notificationsFuture = _fetchNotifications();
    });
  }

  void _showNotificationDetails(BuildContext context, dynamic notification) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(notification['title']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notification['content'],
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                timeago.format(DateTime.parse(notification['timestamp'])),
                style: TextStyle(
                  fontSize: 10.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Mark the notification as read after closing the dialog
      if (!notification['read']) {
        _markAsRead(notification['_id']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
              ),
              onPressed: _markAllAsRead,
              child: Text(
                'Read All',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading notifications'));
          } else {
            final notifications = snapshot.data!.reversed.toList(); // Reverse the list
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return GestureDetector(
                  onTap: () => _showNotificationDetails(context, notification),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: notification['read'] ? LinoColors.primary : LinoColors.accent,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['title'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: notification['read'] ? FontWeight.normal : FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          notification['content'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                            fontSize: notification['read'] ? 12.0 : 14.0,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          timeago.format(DateTime.parse(notification['timestamp'])),
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
