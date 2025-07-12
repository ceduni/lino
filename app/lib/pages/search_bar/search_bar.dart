import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Lino_app/services/book_services.dart';

class SearchController extends GetxController {
  var query = ''.obs;
  var results = <String>[].obs;
  final FocusNode focusNode = FocusNode();

  void showSearchResults(String query) {
    this.query.value = query;
  }

  void hideSearchResults() {
    this.query.value = '';
    results.clear();
    focusNode.unfocus();
  }

  Future<void> search(String query) async {
    this.query.value = query;
    if (query.isEmpty) {
      results.clear();
    } else {
      var bookResults = await BookService().searchBooks(kw: query);
      results.clear();
      for (var book in bookResults) {
        results.add(book.title);
      }
    }
  }

  @override
  void onClose() {
    focusNode.dispose();
    super.onClose();
  }
}

class LinoSearchBar extends StatelessWidget {
  final int sourcePage;
  LinoSearchBar({super.key, required this.sourcePage});

  final SearchController searchController = Get.put(SearchController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Unfocus when tapping outside
      },
      child: SizedBox(
        height: 40.0,
        child: TextField(
          focusNode: searchController.focusNode,
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
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  final int sourcePage;

  SearchPage({required this.sourcePage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Unfocus when tapping outside
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Search Page'),
        ),
        body: Center(
          child: LinoSearchBar(sourcePage: sourcePage),
        ),
      ),
    );
  }
}
