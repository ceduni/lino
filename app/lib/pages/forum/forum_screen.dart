import 'package:flutter/material.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'threads_section.dart';
import 'requests_section.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: LinoColors.primary,
          title: const Text('Forum'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Threads'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ThreadsSection(),
            RequestsSection(),
          ],
        ),
      ),
    );
  }
}
