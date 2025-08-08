import 'package:Lino_app/models/user_model.dart';
import 'package:flutter/material.dart';

class EcologicalImpactCard extends StatelessWidget {
  final User user;

  const EcologicalImpactCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    int numSavedBooks = user.numSavedBooks;

    // Calculate ecological impact based on numSavedBooks
    double carbonSavings = numSavedBooks * 27.71;
    double savedWater = numSavedBooks * 2000.0;
    double savedTrees = numSavedBooks * 0.05;

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
                    value: savedTrees.toStringAsFixed(2),
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