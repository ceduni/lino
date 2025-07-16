import 'package:flutter/material.dart';
import 'package:Lino_app/utils/constants/colors.dart';

class HomeProfileSummary extends StatelessWidget {
  final String username;
  final int numSavedBooks;
  final double savedTrees;
  final double carbonSavings;
  final VoidCallback? onTap;

  const HomeProfileSummary({
    super.key,
    required this.username,
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
              const Color.fromARGB(255, 13, 102, 255).withOpacity(0.8),
              const Color.fromARGB(255, 0, 187, 255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : 'U',
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
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  // Impact summary
                  Row(
                    children: [
                      _buildQuickStat(
                        icon: Icons.book,
                        value: numSavedBooks.toString(),
                        label: 'books',
                      ),
                      SizedBox(width: 16),
                      _buildQuickStat(
                        icon: Icons.eco,
                        value: _formatImpact(),
                        label: _getImpactLabel(),
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
          color: Colors.white.withOpacity(0.8),
          size: 16,
        ),
        SizedBox(width: 4),
        Text(
          '$value $label',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatImpact() {
    // Choose the most impressive stat to highlight
    if (savedTrees >= 1.0) {
      return savedTrees.toStringAsFixed(1);
    } else if (carbonSavings >= 100) {
      return '${(carbonSavings / 1000).toStringAsFixed(1)}kg';
    } else {
      return carbonSavings.toStringAsFixed(0);
    }
  }

  String _getImpactLabel() {
    if (savedTrees >= 1.0) {
      return 'trees saved';
    } else if (carbonSavings >= 100) {
      return 'CO₂ saved';
    } else {
      return 'kg of carbon saved';
    }
  }
}
