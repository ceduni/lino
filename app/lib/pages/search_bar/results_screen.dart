import 'package:flutter/material.dart';
import 'package:Lino_app/pages/search_bar/books_list.dart';
import 'package:Lino_app/pages/search_bar/bookboxes_list.dart';
import 'package:Lino_app/pages/search_bar/threads_list.dart';

class ResultsPage extends StatefulWidget {
  final String query;
  final int sourcePage;
  final VoidCallback onBack;

  const ResultsPage({required this.query, required this.sourcePage, required this.onBack});

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late int sourcePage;

  @override
  void initState() {
    super.initState();
    sourcePage = widget.sourcePage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onBack,
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  sourcePage = 1; // Switch to BookBoxesList
                });
              },
              child: Text(
                'Show results for bookboxes',
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  sourcePage = 2; // Switch to ThreadsList
                });
              },
              child: Text(
                'Show results for threads',
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ),
          BooksList(query: widget.query),
        ]);
        break;
      case 1:
        sections.addAll([
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  sourcePage = 0; // Switch to BooksList
                });
              },
              child: Text(
                'Show results for books',
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  sourcePage = 2; // Switch to ThreadsList
                });
              },
              child: Text(
                'Show results for threads',
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ),
          BookBoxesList(query: widget.query),
        ]);
        break;
      case 2:
        sections.addAll([
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  sourcePage = 0; // Switch to BooksList
                });
              },
              child: Text(
                'Show results for books',
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  sourcePage = 1; // Switch to BookBoxesList
                });
              },
              child: Text(
                'Show results for bookboxes',
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ),
          ThreadsList(query: widget.query),
        ]);
        break;
      default:
        sections.addAll([
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  sourcePage = 1; // Switch to BookBoxesList
                });
              },
              child: Text(
                'Show results for bookboxes',
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  sourcePage = 2; // Switch to ThreadsList
                });
              },
              child: Text(
                'Show results for threads',
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ),
          BooksList(query: widget.query),
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
      padding: const EdgeInsets.all(12.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
