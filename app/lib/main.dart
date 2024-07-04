import 'package:flutter/material.dart';
import 'navigation.dart';
import 'Discussion.dart';

// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/map_page.dart';
import 'models/bookbox_model.dart';

void main() {
  runApp(MyApp());
}

var bookboxes = [
  BookBox(
    name: 'BookBox 1',
    location: [1.0, 2.0],
    infoText: 'Info 1',
    books: ['Book 1', 'Book 2', 'Book 3'],
  ),
  BookBox(
    name: 'BookBox 2',
    location: [3.0, 4.0],
    infoText: 'Info 2',
    books: ['Book 4', 'Book 5', 'Book 6'],
  ),
  BookBox(
    name: 'BookBox 3',
    location: [5.0, 6.0],
    infoText: 'Info 3',
    books: ['Book 7', 'Book 8', 'Book 9'],
  ),
  BookBox(
    name: 'BookBox 4',
    location: [7.0, 8.0],
    infoText: 'Info 4',
    books: ['Book 10', 'Book 11', 'Book 12'],
  ),
  BookBox(
    name: 'BookBox 5',
    location: [9.0, 10.0],
    infoText: 'Info 5',
    books: ['Book 13', 'Book 14', 'Book 15'],
  ),
  BookBox(
    name: 'BookBox 6',
    location: [11.0, 12.0],
    infoText: 'Info 6',
    books: ['Book 16', 'Book 17', 'Book 18'],
  ),
  BookBox(
    name: 'BookBox 7',
    location: [13.0, 14.0],
    infoText: 'Info 7',
    books: ['Book 19', 'Book 20', 'Book 21'],
  ),
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lino App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 170, 193, 251)),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    NavigationPage(),
    DiscussionPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search_sharp),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Navigation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: 'Discussion',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromRGBO(249, 143, 110, 1),
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 600, // Adjust the width as needed
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.mic),
                    onPressed: () {
                      // Define the action when the microphone icon is pressed
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onTap: () {
                  showSearch(
                    context: context,
                    delegate: CustomSearchDelegate(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  // List of search terms
  List<String> searchTerms = [
    "SIUUUUU",
    "Banana",
    "Mango",
    "Pear",
    "Watermelons",
    "Blueberries",
    "Pineapples",
    "Strawberries"
  ];

  // Clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  // Pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  // Show query result
  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in searchTerms) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  // Show suggestions as the user types
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var fruit in searchTerms) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () {
            query = result;
            showResults(context);
          },
        );
      },
    );
  }
}