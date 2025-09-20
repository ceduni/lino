// app/lib/views/notifications_setting_page.dart
import 'package:Lino_app/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/profile/options_view_model.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/l10n/app_localizations.dart';

class NotificationSettingPage extends StatefulWidget {
  const NotificationSettingPage({super.key});

  @override
  _NotificationSettingPageState createState() => _NotificationSettingPageState();
}

class _NotificationSettingPageState extends State<NotificationSettingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OptionsViewModel>().loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.notificationSettings),
      ),
      body: Consumer<OptionsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                    children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                      children: [
                        /*
                        _buildOptionTile(
                        icon: Icons.person,
                        title: 'Modify Profile',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ModifyProfilePage()),
                        ),
                        ),
                        SizedBox(height: 10),
                        _buildOptionTile(
                        icon: Icons.favorite,
                        title: 'Setup Favourite Genres',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FavouriteGenresPage()),
                        ),
                        ),
                        SizedBox(height: 10),
                        _buildOptionTile(
                        icon: Icons.location_on,
                        title: 'Favourite Locations',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FavouriteLocationsPage()),
                        ),
                        ),
                        SizedBox(height: 20),
                        */
                        _buildNotificationSection(viewModel, localizations),
                      ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: LinoColors.primary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.black),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNotificationSection(OptionsViewModel viewModel, AppLocalizations localizations) {
    return Column(
      children: [
        /*
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
        */
        Container(
          decoration: BoxDecoration(
        color: LinoColors.primary,
        borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
        children: [
          _buildNotificationTile(
            icon: Icons.book_outlined,
            title: localizations.newbooknotifications,
            subtitle: localizations.getnotifiedwhenbooksmatchingyourpreferencesareaddedtobookboxesyoufolloworinyourfavoritelocations,
            value: viewModel.addedBookNotifications,
            onChanged: (value) async {
          final success = await viewModel.toggleNotification('addedBook');
          if (!success) {
            CustomSnackbars.error(
              'Error',
              'Failed to update notification settings',
            );
          }
            },
          ),
          Divider(height: 1, color: Colors.black26),
          _buildNotificationTile(
            icon: Icons.request_page_outlined,
            title: localizations.bookRequestnotifications,
            subtitle: localizations.getnotifiedwhensomeonerequestsabookfromyou,
            value: viewModel.bookRequestedNotifications,
            onChanged: (value) async {
          final success = await viewModel.toggleNotification('bookRequested');
          if (!success) {
            CustomSnackbars.error(
              'Error',
              'Failed to update notification settings',
            );
          }
            },
          ),
        ],
          ),
        ),
        /*
        SizedBox(height: 20),
        Container(
          width: 120,
          height: 40,
          child: ElevatedButton(
        onPressed: () => context.read<ProfileViewModel>().disconnect(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.white, size: 18),
            SizedBox(width: 4),
            Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
          ),
        ),
        */
      ],
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.black54),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
    );
  }
}