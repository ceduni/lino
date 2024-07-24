import 'package:Lino_app/pages/search_bar/results_screen.dart';
import 'package:Lino_app/services/book_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  var query = ''.obs;
  var results = <String>[].obs;

  Future<void> search(String query) async {
    this.query.value = query;
    if (query.isEmpty) {
      results.clear();
    } else {
      // Implement your search logic here
      var bookDict = await BookService().searchBooks(kw: query);
      var bookResults = bookDict['books'];
      bookResults.forEach((book) {
        results.add(book['title']);
      });
    }
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
