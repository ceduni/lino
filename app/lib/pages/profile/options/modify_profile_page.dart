import 'package:flutter/material.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../services/user_services.dart';

class ModifyProfilePage extends StatefulWidget {
  @override
  _ModifyProfilePageState createState() => _ModifyProfilePageState();
}

class _ModifyProfilePageState extends State<ModifyProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool? _getAlerted;
  late String _token;
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token')!;
    final userService = UserService();
    final user = await userService.getUser(_token);

    setState(() {
      _usernameController = TextEditingController(text: user['user']['username']);
      _passwordController = TextEditingController(text: '');
      _emailController = TextEditingController(text: user['user']['email']);
      _phoneController = TextEditingController(text: user['user']['phone']);
      _getAlerted = user['user']['getAlerted'];
      _isLoading = false; // Set loading state to false
    });
  }

  Future<void> _updateUser() async {
    final userService = UserService();
    try {
      final response = await userService.updateUser(
        _token,
        username: _usernameController.text,
        password: _passwordController.text.isEmpty ? null : _passwordController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        getAlerted: _getAlerted,
      );
      showToast('Profile updated successfully');
      Navigator.pop(context);
    } catch (e) {
      showToast('Failed to update profile');
      print('Failed to update profile: $e');
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Changes'),
        content: Text('Are you sure you want to update your profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              _updateUser();
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Profile'),
      ),
      body: _isLoading // Show loading indicator if still loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              SwitchListTile(
                title: Text('Get Alerts'),
                value: _getAlerted ?? false,
                onChanged: (bool value) {
                  setState(() {
                    _getAlerted = value;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: Text('Dismiss'),
                  ),
                  ElevatedButton(
                    onPressed: _showConfirmationDialog,
                    style: ElevatedButton.styleFrom(backgroundColor: LinoColors.primary),
                    child: Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}