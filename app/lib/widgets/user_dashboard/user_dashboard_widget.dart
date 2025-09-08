import 'package:Lino_app/utils/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:Lino_app/models/user_model.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/vm/profile/profile_view_model.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'recent_transactions_widget.dart';
import 'followed_bookboxes_widget.dart';

class UserDashboard extends StatefulWidget {
  final User user;

  const UserDashboard({
    super.key,
    required this.user,
  });

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildProfileHeader(),
          ),
          
          _buildProfileManagementSection(),
          
          FollowedBookboxesWidget(user: widget.user),
      
          RecentTransactionsCard(user: widget.user),
          SizedBox(height: 20),
          Center( child:
          SizedBox(
                      width: 240,
                      height: 60,
                      child: ElevatedButton(
                    onPressed: () => context.read<ProfileViewModel>().disconnect(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Logout',
                          style: TextStyle(color: Colors.white, fontSize: 18)
                          ,
                        ),
                      ],
                    ),
                    
                      ),
                    
                    ),
          ),
          SizedBox(height: 40),
 
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.profile.modify),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.lightBlue[100],
                  backgroundImage: widget.user.profilePictureUrl != null && widget.user.profilePictureUrl!.isNotEmpty
                      ? NetworkImage(widget.user.profilePictureUrl!)
                      : null,
                  child: widget.user.profilePictureUrl == null || widget.user.profilePictureUrl!.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: LinoColors.accent,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        
      ],
    );
  }

  Widget _buildProfileManagementSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.favorite,
            title: 'Favorite Genres',
            subtitle: 'Set up your reading preferences',
            onTap: () => Get.toNamed(AppRoutes.profile.favouriteGenres),
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.location_on,
            title: 'Favorite Locations',
            subtitle: 'Manage your preferred locations',
            onTap: () => Get.toNamed(AppRoutes.profile.favouriteLocations),
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Notification Settings',
            subtitle: 'Manage your notifications',
            onTap: () => Get.toNamed(AppRoutes.profile.setupNotifications),
          ),
          
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: LinoColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: LinoColors.accent),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
