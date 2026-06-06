import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lino_app/models/notification_model.dart';
import 'package:lino_app/services/user_services.dart';
import 'package:lino_app/vm/profile/notifications_view_model.dart';
import 'package:lino_app/l10n/app_localizations.dart';
import 'package:lino_app/utils/constants/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsSectionWidget extends StatefulWidget {
  final List<Notif> notifications;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;
  final VoidCallback onNotificationRead;

  const NotificationsSectionWidget({
    super.key,
    required this.notifications,
    required this.isLoading,
    this.error,
    required this.onRefresh,
    required this.onNotificationRead,
  });

  @override
  State<NotificationsSectionWidget> createState() => _NotificationsSectionWidgetState();
}

class _NotificationsSectionWidgetState extends State<NotificationsSectionWidget> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(localizations),
              const SizedBox(height: 12),
              _buildContent(localizations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          localizations.homeRecentNotifications,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit',
          ),
        ),
        Row(
          children: [
            if (widget.isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else ...[
              IconButton(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: localizations.refreshNotifications,
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.home.notifications),
                child: Text(localizations.viewall),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildContent(AppLocalizations localizations) {
    if (widget.isLoading) {
      return _buildLoadingPlaceholder();
    } else if (widget.error != null) {
      return _buildErrorState(localizations);
    } else if (widget.notifications.isEmpty) {
      return _buildEmptyState(localizations);
    } else {
      return _buildNotificationsList(localizations);
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Column(
      children: List.generate(
        3,
        (index) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          child: ListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            title: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            subtitle: Container(
              height: 12,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          Text(
            localizations.unableToLoadNotifications,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            localizations.checkInternetConnection,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(localizations.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Icon(Icons.notifications_none, color: Colors.grey, size: 32),
          const SizedBox(height: 8),
          Text(
            localizations.homeNotificationsEmpty,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(AppLocalizations localizations) {
    return Column(
      children: widget.notifications.map((notification) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
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
            onTap: () {
              _showNotificationDetails(context, notification);
            },
          ),
        );
      }).toList(),
    );
  }

  void _showNotificationDetails(BuildContext context, Notif notification) async {
    final List<String> reasons = notification.reason;
    final localizations = AppLocalizations.of(context)!;

    String title;
    if (reasons.contains('book_request')) {
      title = localizations.bookRequest;
    } else {
      title = localizations.newBookAvailable;
    }

    // Create a temporary view model to use its methods
    final tempViewModel = NotificationsViewModel();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: FutureBuilder<String>(
            future: tempViewModel.buildNotificationContent(notification, localizations),
            builder: (context, snapshot) {
              String content;
              if (snapshot.connectionState == ConnectionState.waiting) {
                content = localizations.loading;
              } else if (snapshot.hasError) {
                content = tempViewModel.buildNotificationContentSync(notification, localizations);
              } else {
                content = snapshot.data ??
                    tempViewModel.buildNotificationContentSync(notification, localizations);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    content,
                    style: const TextStyle(),
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
      _markNotificationAsRead(notification);
    });
  }

  Future<void> _markNotificationAsRead(Notif notification) async {
    if (!notification.isRead) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token != null) {
          final userService = UserService();
          await userService.markNotificationAsRead(token, notification.id);
          // Notify parent to refresh notifications
          widget.onNotificationRead();
        }
      } catch (e) {
        print('Error marking notification as read: $e');
      }
    }
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
        case 'solved_book_request':
          formattedReasons.add(localizations.matchesYourBookRequest);
        case 'fav_bookbox':
          formattedReasons.add(localizations.addedToFollowedBookboxPreview);
        case 'same_borough':
          formattedReasons.add(localizations.addedNearYou);
        case 'fav_genre':
          formattedReasons.add(localizations.matchesYourFavoriteGenre);
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
}