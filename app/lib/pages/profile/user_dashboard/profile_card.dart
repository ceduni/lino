import 'package:Lino_app/pages/profile/options/modify_profile_page.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String username;
  final double savedTrees;
  final int numSavedBooks;
  final DateTime createdAt;
  final bool includeModifyButton;

  const ProfileCard({
    super.key,
    required this.username,
    required this.savedTrees,
    required this.numSavedBooks,
    required this.createdAt,
    this.includeModifyButton = false,
  });

  @override
  Widget build(BuildContext context) {
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
                  backgroundImage: Image.network('https://imgs.search.brave.com/M3mi-is8_3t7e0PSznN7CZl9wCDVz6B_7hiUc3zgp3o/rs:fit:500:0:0:0/g:ce/aHR0cHM6Ly9jZG40/Lmljb25maW5kZXIu/Y29tL2RhdGEvaWNv/bnMvc3BvdHMvNTEy/L2ZhY2Utd29tYW4t/MTI4LnBuZw').image,
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
            Text(
              username,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _getMemberSinceText(),
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

  String _getMemberSinceText() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return 'Member since $years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return 'Member since $months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays >= 1) {
      return 'Member since ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours >= 1) {
      return 'Member since ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes >= 1) {
      return 'Member since ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Member since just now';
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
