// app/lib/pages/home/home_authenticated_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:lino/vm/home/home_view_model.dart';
import 'package:lino/vm/bookboxes/bookbox_list_view_model.dart';
import 'package:lino/widgets/profile_stats_widget.dart';
import 'package:lino/views/home/widgets/notifications_section.dart';
import 'package:lino/views/home/widgets/map_section.dart';
import 'package:lino/utils/constants/routes.dart';
import 'package:lino/utils/constants/colors.dart';
import 'package:lino/models/notification_model.dart';
import 'package:lino/l10n/app_localizations.dart';

class HomeAuthenticatedView extends StatelessWidget {
  final HomeViewModel viewModel;
  final List<Notif> notifications;
  final bool loadingNotifications;
  final String? notificationError;
  final VoidCallback onRefreshNotifications;
  final VoidCallback onNotificationRead;

  const HomeAuthenticatedView({
    super.key,
    required this.viewModel,
    required this.notifications,
    required this.loadingNotifications,
    this.notificationError,
    required this.onRefreshNotifications,
    required this.onNotificationRead,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Consumer<BookboxListViewModel>(
      builder: (context, bookboxViewModel, child) {
        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Stats
                      MergedProfileStatsWidget(
                        userName: viewModel.userData!.username,
                        booksSaved: viewModel.userData!.numSavedBooks,
                        treesSaved: viewModel.userData!.ecologicalImpact.savedTrees,
                        profilePictureUrl: viewModel.userData!.profilePictureUrl,
                      ),

                      // Notifications Section Widget
                      NotificationsSectionWidget(
                        notifications: notifications,
                        isLoading: loadingNotifications,
                        error: notificationError,
                        onRefresh: onRefreshNotifications,
                        onNotificationRead: onNotificationRead,
                      ),

                      // Map Widget
                      Container(
                        height: 300,
                        margin: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: MapWidget(
                              viewModel: viewModel,
                              localizations: localizations,
                              showCard: false,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Get.toNamed(AppRoutes.scan.qrScanner),
            backgroundColor: LinoColors.accent,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(
              localizations.scan,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}