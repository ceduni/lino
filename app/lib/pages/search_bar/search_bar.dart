import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Lino_app/services/book_services.dart';

class SearchController extends GetxController {
  var query = ''.obs;
  var results = <String>[].obs;

  void showSearchResults(String query) {
    this.query.value = query;
  }

  void hideSearchResults() {
    this.query.value = '';
    results.clear();
  }

  Future<void> search(String query) async {
    this.query.value = query;
    if (query.isEmpty) {
      results.clear();
    } else {
      var bookDict = await BookService().searchBooks(kw: query);
      var bookResults = bookDict['books'];
      results.clear();
      bookResults.forEach((book) {
        results.add(book['title']);
      });
    }
  }
}


class LinoSearchBar extends StatelessWidget {
  final int sourcePage;
  LinoSearchBar({super.key, required this.sourcePage});

  final SearchController searchController = Get.put(SearchController());

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.0,
      child: TextField(
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            searchController.showSearchResults(value);
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
          contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
        ),
      ),
    );
  }
}