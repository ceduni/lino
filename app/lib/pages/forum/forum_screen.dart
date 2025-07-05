import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'threads_section.dart';
import 'requests_section.dart';

class ForumScreen extends StatefulWidget {
  String? query;

  ForumScreen({super.key, this.query});

  @override
  ForumScreenState createState() => ForumScreenState();
}

class ForumScreenState extends State<ForumScreen> {
  final GlobalKey<ThreadsSectionState> threadsSectionKey = GlobalKey<ThreadsSectionState>();
  final GlobalKey<RequestsSectionState> requestsSectionKey = GlobalKey<RequestsSectionState>();

  Future<bool> isConnected() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  void refreshThreads() {
    threadsSectionKey.currentState?.fetchThreadTiles(cls: 'by creation date', asc: false, q: '');
  }

  void refreshRequests() {
    requestsSectionKey.currentState?.fetchRequests();
  }

  Future<void> _refresh() async {
    refreshThreads();
    refreshRequests();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isConnected(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (!snapshot.hasData || !snapshot.data!) {
          return Scaffold(
            body: Center(
              child: Text(
                'Login or create an account to access the forum page',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: LinoColors.primary,
              centerTitle: true,
              title: const Text('Forum', style: TextStyle(fontWeight: FontWeight.bold)),
              bottom: const TabBar(
                unselectedLabelColor: Colors.black,
                indicatorColor: LinoColors.secondary,
                labelColor: LinoColors.secondary,
                tabs: [
                  Tab(text: 'Threads'),
                  Tab(text: 'Requests'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                RefreshIndicator(
                  onRefresh: _refresh,
                  child: ThreadsSection(key: threadsSectionKey, query: widget.query),
                ),
                RefreshIndicator(
                  onRefresh: _refresh,
                  child: RequestsSection(key: requestsSectionKey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
