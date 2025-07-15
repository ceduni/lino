import 'package:flutter/material.dart';
import 'package:Lino_app/pages/profile/user_dashboard/profile_card.dart';
import 'recent_transactions_widget.dart';

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
            savedTrees: widget.savedTrees,
            numSavedBooks: widget.numSavedBooks,
            createdAt: widget.createdAt,
            includeModifyButton: true,
          ),
          EcologicalImpactCard(
            carbonSavings: widget.carbonSavings,
            savedWater: widget.savedWater,
            savedTrees: widget.savedTrees,
            numSavedBooks: widget.numSavedBooks,
          ),
          RecentTransactionsCard(
            username: widget.username,
          ),
        ],
      ),
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
