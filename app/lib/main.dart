import 'package:Lino_app/widgets/bottom_app_bar.dart';
import 'package:Lino_app/widgets/floating_menu.dart';
import 'package:Lino_app/widgets/search_app_bar.dart';
import 'package:flutter/material.dart';

// lib/main.dart
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

// Changes here will apply to all pages
class _MainScreenState extends State<MainScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      CustomNavBar(),
      
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
            SearchAppBar(
            onUserIconPressed: () {
              // Handle user icon pressed
              print("User icon pressed");
            },
            onMenuPressed: () {
              // Handle menu icon pressed
              print("Menu icon pressed");
            },
            )
          ],
        ),
      ),
    );
  }
}
