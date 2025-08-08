import 'package:Lino_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:Lino_app/utils/constants/colors.dart';

class HomeProfileSummary extends StatelessWidget {
  final User user;
  final int numSavedBooks;
  final double savedTrees;
  final double carbonSavings;
  final VoidCallback? onTap;

  const HomeProfileSummary({
    super.key,
    required this.user,
    required this.numSavedBooks,
    required this.savedTrees,
    required this.carbonSavings,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              LinoColors.secondary.withValues(alpha: 0.8),
              LinoColors.accent.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 16),
            
            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                    Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                      user.username,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      ),
                      SizedBox(width: 3),
                      if (user.isAdmin)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Icon(
                        Icons.shield,
                        color: const Color.fromARGB(255, 212, 212, 212),
                        ),
                      ),
                    ],
                    ),
                  SizedBox(height: 8),
                  
                  // Impact summary
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickStat(
                        icon: Icons.book,
                        value: numSavedBooks.toString(),
                        label: 'books saved',
                      ),
                      SizedBox(width: 10),
                      _buildDescription(
                        icon: Icons.eco,
                        label: getMatchingDescription(savedTrees),
                        
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            
          ],
        ),
      ),
    );
  }

  static const descriptionList = [
    'Tree Hugger in Training',
    'Carbon Crusader',
    'Eco Warrior',
    'Planet Protector',
    'Environmental Champion'
  ];

  String getMatchingDescription(double savedTrees) {
    if (numSavedBooks >= 100) {
      return descriptionList[4];
    } else if (numSavedBooks >= 50) {
      return descriptionList[3];
    } else if (numSavedBooks >= 20) {
      return descriptionList[2];
    } else if (numSavedBooks >= 10) {
      return descriptionList[1];
    } else {
      return descriptionList[0];
    }
  }
  
  
  Widget _buildDescription({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 16,
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 16,
        ),
        SizedBox(width: 4),
        Text(
          '$value $label',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // String _formatImpact() {
  //   // Choose the most impressive stat to highlight
  //   if (savedTrees >= 1.0) {
  //     return savedTrees.toStringAsFixed(1);
  //   } else if (carbonSavings >= 100) {
  //     return '${(carbonSavings / 1000).toStringAsFixed(1)}';
  //   } else {
  //     return carbonSavings.toStringAsFixed(0);
  //   }
  // }

  // String _getImpactLabel() {
  //   if (savedTrees >= 1.0) {
  //     return 'trees saved';
  //   } else if (carbonSavings >= 100) {
  //     return 'CO₂ saved';
  //   } else {
  //     return 'kg of carbon saved';
  //   }
  // }
}
