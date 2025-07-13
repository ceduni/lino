import 'package:Lino_app/services/bookbox_services.dart';
import 'package:flutter/material.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:Lino_app/models/notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:Lino_app/utils/constants/colors.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<Notif>> _notificationsFuture;
  late String _token;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchNotifications();
  }

  Future<List<Notif>> _fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token')!;
    return await UserService().getUserNotifications(_token);
  }

  Future<void> _markAsRead(String id) async {
    await UserService().markNotificationAsRead(_token, id);
    setState(() {
      _notificationsFuture = _fetchNotifications();
    });
  }

  Future<void> _markAllAsRead() async {
    final notifications = await _notificationsFuture;
    for (var notification in notifications) {
      if (!notification.isRead) {
        await UserService().markNotificationAsRead(_token, notification.id);
      }
    }
    setState(() {
      _notificationsFuture = _fetchNotifications();
    });
  }

  String _getNotificationTitle(Notif notification) {
    final List<String> reasons = notification.reason;
    if (reasons.isEmpty) {
      return 'Notification';
    }
    if (reasons.contains('book_request')) {
      return 'Book Request';
    } else {
      return 'New Book Available';
    }
  }

  String _getNotificationPreview(Notif notification) {
    final List<String> reasons = notification.reason;
    final String bookTitle = notification.bookTitle;
    if (reasons.isEmpty) {
      return 'No specific reason provided for this notification.';
    }
    if (reasons.contains('book_request')) {
      return 'Someone is looking for "$bookTitle"';
    } else {
      return '"$bookTitle" is now available';
    }
  }

  Future<String> _getBookboxName(String? bookboxId) async {
    if (bookboxId == null || bookboxId.isEmpty) {
      return 'a book box';
    }
    
    try {
      final bookboxData = await BookboxService().getBookBox(bookboxId);
      return bookboxData.name;
    } catch (e) {
      return 'a book box';
    }
  }

  void _showNotificationDetails(BuildContext context, Notif notification) {
    final List<String> reasons = notification.reason;

    String title;
    
    if (reasons.contains('book_request')) {
      title = 'Book Request';
    } else {
      title = 'New Book Available';
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: FutureBuilder<String>(
            future: _buildNotificationContent(notification),
            builder: (context, snapshot) {
              String content;
              if (snapshot.connectionState == ConnectionState.waiting) {
                content = 'Loading...';
              } else if (snapshot.hasError) {
                content = _buildNotificationContentSync(notification);
              } else {
                content = snapshot.data ?? _buildNotificationContentSync(notification);
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    content,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    timeago.format(DateTime.parse(notification.createdAt.toIso8601String())),
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              );
            },
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
      if (!notification.isRead) {
        _markAsRead(notification.id);
      }
    });
  }

  Future<String> _buildNotificationContent(Notif notification) async {
    final List<String> reasons = notification.reason;
    final String bookTitle = notification.bookTitle;
    final String? bookboxId = notification.bookboxId;
    
    if (reasons.contains('book_request')) {
      return 'Someone is looking for "$bookTitle". If you have this book, please consider adding it to the nearest book box to help out!';
    } else {
      final String bookboxName = await _getBookboxName(bookboxId);
      List<String> reasonMessages = [];
      
      if (reasons.contains('fav_bookbox')) {
        reasonMessages.add('it was added to "$bookboxName", a book box you follow');
      }
      if (reasons.contains('same_borough')) {
        reasonMessages.add('it was added to "$bookboxName", a book box near you');
      }
      if (reasons.contains('fav_genre')) {
        reasonMessages.add('it matches one of your favorite genres');
      }
      if (reasons.contains('solved_book_request')) {
        reasonMessages.add('it matches a book request you made');
      }
      
      String reasonText;
      if (reasonMessages.length == 1) {
        reasonText = reasonMessages[0];
      } else if (reasonMessages.length == 2) {
        reasonText = '${reasonMessages[0]} and ${reasonMessages[1]}';
      } else {
        reasonText = '${reasonMessages.sublist(0, reasonMessages.length - 1).join(', ')}, and ${reasonMessages.last}';
      }
      
      return 'Good news! "$bookTitle" is now available because $reasonText.';
    }
  }

  String _buildNotificationContentSync(Notif notification) {
    final List<String> reasons = notification.reason;
    final String bookTitle = notification.bookTitle;

    if (reasons.contains('book_request')) {
      return 'Someone is looking for "$bookTitle". If you have this book, please consider adding it to the nearest book box to help out!';
    } else {
      List<String> reasonMessages = [];
      
      if (reasons.contains('fav_bookbox')) {
        reasonMessages.add('it was added to a book box you follow');
      }
      if (reasons.contains('same_borough')) {
        reasonMessages.add('it was added to a book box near you');
      }
      if (reasons.contains('fav_genre')) {
        reasonMessages.add('it matches one of your favorite genres');
      }
      
      String reasonText;
      if (reasonMessages.length == 1) {
        reasonText = reasonMessages[0];
      } else if (reasonMessages.length == 2) {
        reasonText = '${reasonMessages[0]} and ${reasonMessages[1]}';
      } else {
        reasonText = '${reasonMessages.sublist(0, reasonMessages.length - 1).join(', ')}, and ${reasonMessages.last}';
      }
      
      return 'Good news! "$bookTitle" is now available because $reasonText.';
    }
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
      body: FutureBuilder<List<Notif>>(
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
                      color: notification.isRead ? LinoColors.primary : LinoColors.accent,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getNotificationTitle(notification),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          _getNotificationPreview(notification),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                            fontSize: notification.isRead ? 12.0 : 14.0,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          timeago.format(notification.createdAt),
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
