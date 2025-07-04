import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';

class UserDashboard extends StatefulWidget {
  final String username;
  final double carbonSavings;
  final double savedWater;
  final double savedTrees;
  final int numSavedBooks;
  final DateTime createdAt;

  const UserDashboard({
    super.key,
    required this.username,
    required this.carbonSavings,
    required this.savedWater,
    required this.savedTrees,
    required this.numSavedBooks,
    required this.createdAt,
  });

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileCard(
            username: widget.username,
            carbonSavings: widget.carbonSavings,
            savedWater: widget.savedWater,
            savedTrees: widget.savedTrees,
            numSavedBooks: widget.numSavedBooks,
            createdAt: widget.createdAt,
          ),
          EcologicalImpactCard(
            carbonSavings: widget.carbonSavings,
            savedWater: widget.savedWater,
            savedTrees: widget.savedTrees,
            numSavedBooks: widget.numSavedBooks,
          ),
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String username;
  final double carbonSavings;
  final double savedWater;
  final double savedTrees;
  final int numSavedBooks;
  final DateTime createdAt;

  const ProfileCard({
    super.key,
    required this.username,
    required this.carbonSavings,
    required this.savedWater,
    required this.savedTrees,
    required this.numSavedBooks,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: LinoColors.primary,
      elevation: 4,
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
                          Expanded(child: _buildStatColumn('${savedTrees.toStringAsFixed(2)}', 'Trees Saved')),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getMemberSinceText(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -30),
                  child: Container(
                    width: 64,
                    height: 70,
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    ),
                    
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    IconButton(
                    onPressed: () {
                      print("todo");
                    },
                    icon: Icon(
                      Icons.history,
                      size: 30,
                      color: Colors.grey[600],
                    ),
                    padding: EdgeInsets.zero,
                    ),
                    Text(
                    'History',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    ),
                  ],
                  ),
                ),
                ),
              ],
            ),
            SizedBox(height: 0),
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
      return 'Member since ${years} year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return 'Member since ${months} month${months > 1 ? 's' : ''} ago';
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

class EcologicalImpactCard extends StatelessWidget {
  final double carbonSavings;
  final double savedWater;
  final double savedTrees;
  final int numSavedBooks;

  const EcologicalImpactCard({
    super.key,
    required this.carbonSavings,
    required this.savedWater,
    required this.savedTrees,
    required this.numSavedBooks,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ecological Impact',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildImpactItem(
                    icon: Icons.eco,
                    value: '${carbonSavings.toStringAsFixed(2)} kg',
                    label: 'Carbon Saved',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildImpactItem(
                    icon: Icons.water_drop,
                    value: '${savedWater.toStringAsFixed(0)} L',
                    label: 'Water Saved',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildImpactItem(
                    icon: Icons.park,
                    value: '${savedTrees.toStringAsFixed(2)}',
                    label: 'Trees Saved',
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Every book you save makes a difference! Keep up the great work.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: color,
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
