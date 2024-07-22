import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Lino_app/common/widgets/appbar/search_bar.dart' as search_bar;

class ResultsPage extends StatelessWidget {
  final String query;

  const ResultsPage({required this.query, super.key});

  @override
  Widget build(BuildContext context) {
    // Use a post-frame callback to ensure the search is performed after the build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final search_bar.SearchController searchController = Get.find();
      searchController.search(query);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "$query"'),
      ),
      body: Obx(() {
        final search_bar.SearchController searchController = Get.find();
        return ListView.builder(
          itemCount: searchController.results.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(searchController.results[index]),
            );
          },
        );
      }),
    );
  }
}
