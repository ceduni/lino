import 'package:Lino_app/utils/mock_data/mock_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  var query = ''.obs;
  var results = <String>[].obs;

  void search(String query) {
    this.query.value = query;

    if (query.isEmpty) {
      results.clear();
    } else {
      // Implement your search logic here
      results.value = MockData.getBooks()
          .map((book) => book.title)
          .toList()
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}

class ResultsPage extends StatelessWidget {
  final String query;

  const ResultsPage({required this.query, super.key});

  @override
  Widget build(BuildContext context) {
    // Use a post-frame callback to ensure the search is performed after the build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final SearchController searchController = Get.find();
      searchController.search(query);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "$query"'),
      ),
      body: Obx(() {
        final SearchController searchController = Get.find();
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

class LinoSearchBar extends StatelessWidget {
  LinoSearchBar({super.key});

  final SearchController searchController = Get.put(SearchController());

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsPage(query: value),
            ),
          );
        }
      },
      onChanged: (value) {
        searchController.search(value);
      },
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
