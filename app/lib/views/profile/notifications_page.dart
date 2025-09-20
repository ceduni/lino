// app/lib/views/profile/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:Lino_app/l10n/app_localizations.dart';
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
      final localizations = AppLocalizations.of(context);
      context.read<NotificationsViewModel>().initialize(localizations);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Consumer<NotificationsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(localizations.homeRecentNotifications),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
                  ),
                  onPressed: viewModel.isLoading ? null : () => viewModel.markAllAsRead(localizations),
                  child: Text(
                    localizations.markAllAsRead,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          body: _buildBody(viewModel, localizations),
        );
      },
    );
  }

  Widget _buildBody(NotificationsViewModel viewModel, AppLocalizations localizations) {
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
              onPressed: () => viewModel.fetchNotifications(localizations),
              child: Text(localizations.retry),
            ),
          ],
        ),
      );
    }

    if (viewModel.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              localizations.homeNotificationsEmpty,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchNotifications(localizations),
      child: ListView.builder(
        itemCount: viewModel.notifications.length,
        itemBuilder: (context, index) {
          final notification = viewModel.notifications[index];
          return _buildNotificationItem(notification, viewModel, localizations);
        },
      ),
    );
  }

  Widget _buildNotificationItem(Notif notification, NotificationsViewModel viewModel, AppLocalizations localizations) {
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
                _formatNotificationReason(notification.reason, localizations),
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              _formatNotificationDate(notification.createdAt, localizations),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _showNotificationDetails(context, notification, viewModel, localizations),
      ),
    );
  }

  String _formatNotificationDate(DateTime date, AppLocalizations localizations) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}${localizations.daysAgo}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${localizations.hoursAgo}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${localizations.minutesAgo}';
    } else {
      return localizations.justNow;
    }
  }

  String _formatNotificationReason(List<String> reasons, AppLocalizations localizations) {
    if (reasons.isEmpty) {
      return localizations.newNotification;
    }

    List<String> formattedReasons = [];
    
    for (String reason in reasons) {
      switch (reason) {
        case 'book_request':
          formattedReasons.add(localizations.someoneRequestedThisBook);
          break;
        case 'solved_book_request':
          formattedReasons.add(localizations.matchesYourBookRequest);
          break;
        case 'fav_bookbox':
          formattedReasons.add(localizations.addedToFollowedBookboxPreview);
          break;
        case 'same_borough':
          formattedReasons.add(localizations.addedNearYou);
          break;
        case 'fav_genre':
          formattedReasons.add(localizations.matchesYourFavoriteGenre);
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
      return '${formattedReasons[0]} • ${formattedReasons[1]} • +${formattedReasons.length - 2} ${localizations.andMore}';
    }
  }

  void _showNotificationDetails(BuildContext context, Notif notification, NotificationsViewModel viewModel, AppLocalizations localizations) {
    final List<String> reasons = notification.reason;

    String title;
    if (reasons.contains('book_request')) {
      title = localizations.bookRequest;
    } else {
      title = localizations.newBookAvailable;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: FutureBuilder<String>(
            future: viewModel.buildNotificationContent(notification, localizations),
            builder: (context, snapshot) {
              String content;
              if (snapshot.connectionState == ConnectionState.waiting) {
                content = localizations.loading;
              } else if (snapshot.hasError) {
                content = viewModel.buildNotificationContentSync(notification, localizations);
              } else {
                content = snapshot.data ?? viewModel.buildNotificationContentSync(notification, localizations);
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
              child: Text(localizations.close),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Mark the notification as read after closing the dialog
      viewModel.onNotificationTap(notification, localizations);
    });
  }
}
