import 'package:Lino_app/widgets/user_dashboard/ecological_impact_widget.dart';
import 'package:flutter/material.dart';
import 'package:Lino_app/models/user_model.dart';
import 'package:Lino_app/widgets/user_dashboard/profile_card_widget.dart';
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
        children: [
          ProfileCard(
            user: widget.user,
            includeModifyButton: true,
          ),
          EcologicalImpactCard(
            user: widget.user,
          ),
          FollowedBookboxesWidget(
            user: widget.user,
          ),
          RecentTransactionsCard(
            user: widget.user,
          ),
        ],
      ),
    );
  }
}
