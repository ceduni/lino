// app/lib/pages/search_bar/search_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/search/search_bar_view_model.dart';
import 'package:Lino_app/utils/constants/search_types.dart';

class LinoSearchBar extends StatefulWidget {
  final SearchType searchType;

  const LinoSearchBar({super.key, required this.searchType});

  @override
  State<LinoSearchBar> createState() => _LinoSearchBarState();
}

class _LinoSearchBarState extends State<LinoSearchBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchBarViewModel>().setSearchType(widget.searchType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchBarViewModel>(
      builder: (context, viewModel, child) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SizedBox(
            height: 40.0,
            child: Stack(
              children: [
                TextField(
                  focusNode: viewModel.focusNode,
                  onSubmitted: viewModel.onSubmitted,
                  onChanged: viewModel.search,
                  decoration: InputDecoration(
                    hintText: _getHintText(viewModel.searchType),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: viewModel.isLoading
                        ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0.0,
                      horizontal: 16.0,
                    ),
                  ),
                ),
                if (viewModel.results.isNotEmpty) _buildSearchResults(viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getHintText(SearchType searchType) {
    switch (searchType) {
      case SearchType.books:
        return 'Search books...';
      case SearchType.bookboxes:
        return 'Search bookboxes...';
    }
  }

  Widget _buildSearchResults(SearchBarViewModel viewModel) {
    return Positioned(
      top: 42,
      left: 0,
      right: 0,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: viewModel.results.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(viewModel.results[index]),
                onTap: () {
                  viewModel.showSearchResults(viewModel.results[index]);
                  viewModel.unfocus();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
