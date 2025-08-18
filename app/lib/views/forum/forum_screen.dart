// app/lib/views/forum/forum_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/forum/forum_view_model.dart';
import 'package:Lino_app/views/forum/requests_section.dart';

class ForumScreen extends StatefulWidget {
  final String? query;

  const ForumScreen({super.key, this.query});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ForumViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ForumViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (viewModel.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${viewModel.error}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: viewModel.refresh,
            child: const RequestsSection(),
          ),
        );
      },
    );
  }

}
