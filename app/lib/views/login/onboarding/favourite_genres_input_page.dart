// app/lib/views/favourite_genres_input_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/login/onboarding/favourite_genres_input_view_model.dart';
import '../../../utils/constants/routes.dart';
import 'favourite_locations_input_page.dart';

class FavouriteGenresInputPage extends StatefulWidget {
  const FavouriteGenresInputPage({super.key});

  @override
  _FavouriteGenresInputPageState createState() => _FavouriteGenresInputPageState();
}

class _FavouriteGenresInputPageState extends State<FavouriteGenresInputPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavouriteGenresInputViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4277B8),
      resizeToAvoidBottomInset: false,
      body: Consumer<FavouriteGenresInputViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Header section
                  _buildHeader(),
                  // Content section
                  _buildContent(viewModel),
                  // Bottom buttons section
                  _buildBottomButtons(viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'What genres do you love?',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Select your favourite book genres to get personalized recommendations',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(FavouriteGenresInputViewModel viewModel) {
    return Expanded(
      flex: 4,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!viewModel.showSearchInput) ..._buildPopularGenresSection(viewModel),
            if (viewModel.showSearchInput) ..._buildSearchSection(viewModel),
            SizedBox(height: 20),
            if (viewModel.selectedGenres.isNotEmpty) ..._buildSelectedGenresSection(viewModel),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPopularGenresSection(FavouriteGenresInputViewModel viewModel) {
    return [
      Text(
        'Popular Genres:',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      SizedBox(height: 12),
      Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: viewModel.popularGenres.map((genre) {
          final isSelected = viewModel.selectedGenres.contains(genre);
          return GestureDetector(
            onTap: () => viewModel.toggleGenre(genre),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                genre,
                style: TextStyle(
                  color: isSelected ? Color(0xFF4277B8) : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
      SizedBox(height: 20),
      Center(
        child: OutlinedButton(
          onPressed: viewModel.toggleSearchInput,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.white, width: 1.5),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: Text(
            'Others',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildSearchSection(FavouriteGenresInputViewModel viewModel) {
    return [
      Row(
        children: [
          IconButton(
            onPressed: viewModel.toggleSearchInput,
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: TextField(
              controller: viewModel.genreController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                hintText: 'Search or enter custom genre',
                hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Color(0xFFE0F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => viewModel.addCustomGenre(),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: viewModel.addCustomGenre,
          ),
        ],
      ),
      if (viewModel.showSuggestions) _buildSuggestions(viewModel),
    ];
  }

  Widget _buildSuggestions(FavouriteGenresInputViewModel viewModel) {
    return Container(
      margin: EdgeInsets.only(top: 8, left: 48),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: viewModel.filteredGenres.length,
        itemBuilder: (context, index) {
          final genre = viewModel.filteredGenres[index];
          final query = viewModel.genreController.text.toLowerCase();
          return ListTile(
            title: _buildHighlightedText(genre, query),
            onTap: () => viewModel.addGenre(genre),
            dense: true,
          );
        },
      ),
    );
  }

  List<Widget> _buildSelectedGenresSection(FavouriteGenresInputViewModel viewModel) {
    return [
      Text(
        'Selected Genres:',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      SizedBox(height: 12),
      Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: viewModel.selectedGenres.map((genre) {
          return Chip(
            side: BorderSide(color: Color(0xFF81D4FA)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            label: Text(genre),
            backgroundColor: Color(0xFFE0F7FA),
            deleteIcon: Icon(Icons.close),
            onDeleted: () => viewModel.removeGenre(genre),
          );
        }).toList(),
      ),
    ];
  }

  Widget _buildBottomButtons(FavouriteGenresInputViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Get.offNamed(AppRoutes.home),
            child: Text(
              'Skip',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: viewModel.selectedGenres.isEmpty ? null : () async {
              final success = await viewModel.continueToNext();
              if (success) {
                Get.offNamed(AppRoutes.auth.onboarding.favouriteLocations);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: viewModel.selectedGenres.isEmpty ? Colors.grey : Colors.white,
              foregroundColor: Color(0xFF4277B8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: Text(
              'Continue',
              style: TextStyle(
                color: viewModel.selectedGenres.isEmpty ? Colors.grey[600] : Color(0xFF4277B8),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) return Text(text);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) return Text(text);

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black),
        children: [
          if (index > 0) TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          if (index + query.length < text.length)
            TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }
}