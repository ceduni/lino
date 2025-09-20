// app/lib/views/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/profile/profile_view_model.dart';
import 'package:Lino_app/widgets/user_dashboard/user_dashboard_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh profile data when app comes back to foreground
      context.read<ProfileViewModel>().initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (viewModel.token == null || viewModel.token!.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('User Profile Test'),
            ),
            body: Center(child: Text('No token found. Please log in.')),
          );
        }

        if (viewModel.error != null || viewModel.user == null) {
          return Center(child: Text('Error loading data or user data is null'));
        }

        return Scaffold(
          body: UserDashboard(user: viewModel.user!)
          ,
          
        );
      },
    );
  }
}