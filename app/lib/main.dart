import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart' as api;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login/Signup Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Signup (Nathan, J2s3jAsd)'),
              onPressed: () async {
                var response = await api.ApiService().registerUser('Nathan', 'J2s3jAsd');
                print(response);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LandingPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text('Login (Asp3rity, J2s3jAsd)'),
              onPressed: () async {
                var response = await api.ApiService().loginUser('Asp3rity', 'J2s3jAsd');
                print(response);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LandingPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text('Connect as Guest'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                // Set the token and refreshToken to 'null' to connect as a guest
                // so that only public requests can be made
                prefs.setString('token', 'null');
                prefs.setString('refreshToken', 'null');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LandingPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Landing Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Add Book'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                var token = prefs.getString('token');
                print(token); // Check if token is null
                // Add a book with the ISBN '9782075046480' in the bookbox
                // with the ID '664f81b402a48f9eaaf35eab',
                // using the fetched token
                await api.ApiService().addBook('9782075046480', '664f81b402a48f9eaaf35eab', token!);
              },
            ),
            ElevatedButton(
              child: Text('Try Message'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                var token = prefs.getString('token');
                print(token); // Check if token is null
                // Try to create a thread
                var response = await api.ApiService().createThread(
                    '9782075046480',
                    'I heckin love this book! SPOILER ALERT',
                    token!);
                print(response.body);
                await api.ApiService().createMessage(
                jsonDecode(response.body)['_id'],
                'Sinead dies',
                token);
              },
            ),
          ],
        ),
      ),
    );
  }
}