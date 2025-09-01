// app/lib/views/profile/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:Lino_app/vm/profile/notifications_view_model.dart';
import 'package:Lino_app/models/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
                  ),
                  onPressed: viewModel.isLoading ? null : viewModel.markAllAsRead,
                  child: const Text(
                    'Read All',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          body: _buildBody(viewModel),
        );
      },
    );
  }

  Widget _buildBody(NotificationsViewModel viewModel) {
    if (viewModel.isLoading && viewModel.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null && viewModel.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              viewModel.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.fetchNotifications,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.fetchNotifications,
      child: ListView.builder(
        itemCount: viewModel.notifications.length,
        itemBuilder: (context, index) {
          final notification = viewModel.notifications[index];
          return _buildNotificationItem(notification, viewModel);
        },
      ),
    );
  }

  Widget _buildNotificationItem(Notif notification, NotificationsViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      elevation: 1,
      child: ListTile(
        leading: Icon(
          notification.isRead ? Icons.mail_outline : Icons.mail,
          color: notification.isRead ? Colors.grey : Colors.blue,
        ),
        title: Text(
          notification.bookTitle,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.reason.isNotEmpty)
              Text(
                _formatNotificationReason(notification.reason),
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              _formatNotificationDate(notification.createdAt),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _showNotificationDetails(context, notification, viewModel),
      ),
    );
  }

  String _formatNotificationDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatNotificationReason(List<String> reasons) {
    if (reasons.isEmpty) {
      return 'New notification';
    }

    List<String> formattedReasons = [];
    
    for (String reason in reasons) {
      switch (reason) {
        case 'book_request':
          formattedReasons.add('Someone requested this book');
          break;
        case 'solved_book_request':
          formattedReasons.add('Matches your book request');
          break;
        case 'fav_bookbox':
          formattedReasons.add('Added to followed bookbox');
          break;
        case 'same_borough':
          formattedReasons.add('Added near you');
          break;
        case 'fav_genre':
          formattedReasons.add('Matches your favorite genre');
          break;
        default:
          formattedReasons.add(reason); 
      }
    }

    if (formattedReasons.length == 1) {
      return formattedReasons[0];
    } else if (formattedReasons.length == 2) {
      return '${formattedReasons[0]} • ${formattedReasons[1]}';
    } else {
      return '${formattedReasons[0]} • ${formattedReasons[1]} • +${formattedReasons.length - 2} more';
    }
  }

  void _showNotificationDetails(BuildContext context, Notif notification, NotificationsViewModel viewModel) {
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
            future: viewModel.buildNotificationContent(notification),
            builder: (context, snapshot) {
              String content;
              if (snapshot.connectionState == ConnectionState.waiting) {
                content = 'Loading...';
              } else if (snapshot.hasError) {
                content = viewModel.buildNotificationContentSync(notification);
              } else {
                content = snapshot.data ?? viewModel.buildNotificationContentSync(notification);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    content,
                    style: const TextStyle(
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    timeago.format(notification.createdAt),
                    style: const TextStyle(
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
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Mark the notification as read after closing the dialog
      viewModel.onNotificationTap(notification);
    });
  }
}
