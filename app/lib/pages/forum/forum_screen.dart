import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'threads_section.dart'; // Commented out - threads functionality removed
import 'requests_section.dart';

class ForumScreen extends StatefulWidget {
  final String? query;

  const ForumScreen({super.key, this.query});

  @override
  ForumScreenState createState() => ForumScreenState();
}  

class ForumScreenState extends State<ForumScreen> {
  // final GlobalKey<ThreadsSectionState> threadsSectionKey = GlobalKey<ThreadsSectionState>(); // Commented out - threads functionality removed
  final GlobalKey<RequestsSectionState> requestsSectionKey = GlobalKey<RequestsSectionState>();

  Future<bool> isConnected() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  // void refreshThreads() { // Commented out - threads functionality removed
  //   threadsSectionKey.currentState?.fetchThreadTiles(cls: 'by creation date', asc: false, q: '');
  // }

  void refreshRequests() {
    requestsSectionKey.currentState?.fetchRequests();
  }

  Future<void> _refresh() async {
    // refreshThreads(); // Commented out - threads functionality removed
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
                'Login or create an account to access the requests page',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Removed tab structure - now showing only requests section
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: RequestsSection(key: requestsSectionKey),
          ),
          // body: TabBarView( // Commented out - replaced with direct RequestsSection
          //   children: [
          //     RefreshIndicator(
          //       onRefresh: _refresh,
          //       child: ThreadsSection(key: threadsSectionKey, query: widget.query),
          //     ),
          //     RefreshIndicator(
          //       onRefresh: _refresh,
          //       child: RequestsSection(key: requestsSectionKey),
          //     ),
          //   ],
          // ),
        );
      },
    );
  }
}
