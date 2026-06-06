import 'package:flutter/material.dart';

class CommunityStatsWidget extends StatelessWidget {
  const CommunityStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(66, 119, 184, 1),
            Color.fromRGBO(52, 95, 147, 1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Our Reading Community',
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'UVNDzungDakao',
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.inbox_rounded,
                value: '1,247',
                label: 'BookBoxes',
              ),
              _buildStatDivider(),
              _buildStatItem(
                icon: Icons.swap_horiz_rounded,
                value: '8,532',
                label: 'Exchanges',
              ),
              _buildStatDivider(),
              _buildStatItem(
                icon: Icons.park_rounded,
                value: '342',
                label: 'Trees Saved',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'Kanit-Bold',
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 60,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }
}