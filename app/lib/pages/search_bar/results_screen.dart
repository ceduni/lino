import 'package:flutter/material.dart';
import 'package:Lino_app/pages/search_bar/books_list.dart';
import 'package:Lino_app/pages/search_bar/bookboxes_list.dart';
import 'package:Lino_app/pages/search_bar/threads_list.dart';

class ResultsPage extends StatelessWidget {
  final String query;
  final int sourcePage;
  final VoidCallback onBack;

  const ResultsPage({required this.query, required this.sourcePage, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildSections(),
        ),
      ),
    );
  }

  List<Widget> _buildSections() {
    List<Widget> sections = [];
    switch (sourcePage) {
      case 0:
        sections.addAll([
          SectionTitle(title: 'Books'),
          BooksList(query: query),
          SectionTitle(title: 'Book Boxes'),
          BookBoxesList(query: query),
          SectionTitle(title: 'Threads'),
          ThreadsList(query: query),
        ]);
        break;
      case 1:
        sections.addAll([
          SectionTitle(title: 'Book Boxes'),
          BookBoxesList(query: query),
          SectionTitle(title: 'Books'),
          BooksList(query: query),
          SectionTitle(title: 'Threads'),
          ThreadsList(query: query),
        ]);
        break;
      case 2:
        sections.addAll([
          SectionTitle(title: 'Threads'),
          ThreadsList(query: query),
          SectionTitle(title: 'Books'),
          BooksList(query: query),
          SectionTitle(title: 'Book Boxes'),
          BookBoxesList(query: query),
        ]);
        break;
      default:
        sections.addAll([
          SectionTitle(title: 'Books'),
          BooksList(query: query),
          SectionTitle(title: 'Book Boxes'),
          BookBoxesList(query: query),
          SectionTitle(title: 'Threads'),
          ThreadsList(query: query),
        ]);
        break;
    }

    return sections;
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}