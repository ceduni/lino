import 'package:Lino_app/models/user_model.dart';
import 'package:Lino_app/pages/profile/options/modify_profile_page.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final User user;
  final bool includeModifyButton;

  const ProfileCard({
    super.key,
    required this.user,
    this.includeModifyButton = false,
  });

  @override
  Widget build(BuildContext context) {
    int numSavedBooks = user.numSavedBooks;
    double savedTrees = numSavedBooks * 0.05;

    // Parse createdAt date
    DateTime createdAt = DateTime.parse(user.createdAt.toIso8601String());

    return Card(
      color: LinoColors.primary,
      elevation: includeModifyButton ? 4 : 0,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user.isAdmin ? 
                    Image.network('https://www.pngmart.com/files/21/Admin-Profile-Vector-PNG-Clipart.png').image :
                    Image.network('https://cdn-icons-png.flaticon.com/512/4305/4305692.png').image,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(child: _buildStatColumn('$numSavedBooks', 'Books Saved')),
                          Expanded(child: _buildStatColumn(savedTrees.toStringAsFixed(2), 'Trees Saved')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 3),
                if (user.isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                      child: Icon(
                        Icons.shield,
                        color: Colors.blue,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
              ),
            Text(
              _getMemberSinceText(createdAt),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            includeModifyButton
                ? TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModifyProfilePage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Modify Profile'),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  String _getMemberSinceText(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return '${user.isAdmin ? 'Admin' : 'Member'} since $years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '${user.isAdmin ? 'Admin' : 'Member'} since $months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays >= 1) {
      return '${user.isAdmin ? 'Admin' : 'Member'} since ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours >= 1) {
      return '${user.isAdmin ? 'Admin' : 'Member'} since ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes >= 1) {
      return '${user.isAdmin ? 'Admin' : 'Member'} since ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return '${user.isAdmin ? 'Admin' : 'Member'} since just now';
    }
  }

  Column _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          overflow: TextOverflow.clip,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
