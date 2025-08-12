// app/lib/views/favourite_genres_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/profile/options/favourite_genres_view_model.dart';
import 'package:Lino_app/utils/constants/colors.dart';

class FavouriteGenresPage extends StatefulWidget {
  @override
  _FavouriteGenresPageState createState() => _FavouriteGenresPageState();
}

class _FavouriteGenresPageState extends State<FavouriteGenresPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavouriteGenresViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4277B8),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Setup Favourite Genres'),
        backgroundColor: Color(0xFF4277B8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<FavouriteGenresViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeaderSection(),
                  _buildInputSection(viewModel),
                  SizedBox(height: 20),
                  _buildSelectedGenresSection(viewModel),
                  _buildBottomButtons(viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tell us your favourite genres:',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Select your favourite book genres to get personalized recommendations and notifications',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(FavouriteGenresViewModel viewModel) {
    return Column(
      children: [
        Row(
          children: [
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
      ],
    );
  }

  Widget _buildSuggestions(FavouriteGenresViewModel viewModel) {
    return Container(
      margin: EdgeInsets.only(top: 8),
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

  Widget _buildSelectedGenresSection(FavouriteGenresViewModel viewModel) {
    return Expanded(
      flex: 3,
      child: SingleChildScrollView(
        child: Wrap(
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
      ),
    );
  }

  Widget _buildBottomButtons(FavouriteGenresViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Pass',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              final success = await viewModel.finish();
              if (success) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              backgroundColor: LinoColors.buttonPrimary,
            ),
            child: Text(
              'Finished!',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(text);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(text);
    }

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