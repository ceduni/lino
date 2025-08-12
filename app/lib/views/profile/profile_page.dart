// app/lib/views/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/profile/profile_view_model.dart';
import 'package:Lino_app/widgets/user_dashboard/user_dashboard_widget.dart';
import 'package:Lino_app/views/profile/options_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().initialize();
    });
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
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(125, 200, 237, 1),
            title: Text(viewModel.user!.username),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OptionsPage(),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.settings, color: Colors.white),
                    Text(
                      'Options',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () => viewModel.disconnect(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    Text(
                      'Disconnect',
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
          body: UserDashboard(user: viewModel.user!),
        );
      },
    );
  }
}