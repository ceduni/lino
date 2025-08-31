import 'package:flutter/material.dart';

class MergedProfileStatsWidget extends StatelessWidget {
  final String userName;
  final int booksSaved;
  final double treesSaved;

  const MergedProfileStatsWidget({
    super.key,
    required this.userName,
    required this.booksSaved,
    required this.treesSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile picture
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade100,
            child: Icon(
                    Icons.person,
                    size: 35,
                    color: Colors.blue.shade600,
                  )
          ),
          const SizedBox(width: 16),
          // Name and title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  getMatchingDescription(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Stats section moved to the right
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trees saved
              _buildStatItem(
                icon: Icons.park,
                iconColor: Colors.green.shade600,
                value: treesSaved.toStringAsFixed(2),
                label: 'Trees',
              ),
              const SizedBox(width: 62),
              // Books saved
              _buildStatItem(
                icon: Icons.book,
                iconColor: Colors.orange.shade600,
                value: booksSaved.toString(),
                label: 'Books',
              ),
              const SizedBox(width: 10),
            ],
          ),
          /*
          TextButton(
            onPressed: () {
              print("a faire notis");
            },
            child: Icon(
              Icons.notifications,
              size: 30,
              color: Colors.blue.shade600,
            ),
          ) */
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: iconColor,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  static const descriptionList = [
    'Tree Hugger in Training',
    'Carbon Crusader',
    'Eco Warrior',
    'Planet Protector',
    'Environmental Champion'
  ];

  String getMatchingDescription() {
    if (booksSaved >= 50) {
      return descriptionList[4];
    } else if (booksSaved >= 25) {
      return descriptionList[3];
    } else if (booksSaved >= 10) {
      return descriptionList[2];
    } else if (booksSaved >= 5) {
      return descriptionList[1];
    } else {
      return descriptionList[0];
    }
  }
}