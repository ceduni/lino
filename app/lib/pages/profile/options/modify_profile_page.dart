import 'package:flutter/material.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../services/user_services.dart';

class ModifyProfilePage extends StatefulWidget {
  @override
  _ModifyProfilePageState createState() => _ModifyProfilePageState();
}

class _ModifyProfilePageState extends State<ModifyProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late String _token;
  bool _isLoading = true;
  bool _obscureText = true;

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
      _isLoading = false;
    });
  }

  Future<void> _updateUser() async {
    final userService = UserService();
    try {
      await userService.updateUser(
        _token,
        username: _usernameController.text,
        password: _passwordController.text.isEmpty ? null : _passwordController.text,
        email: _emailController.text,
        phone: _phoneController.text,
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

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        width: double.infinity,
        height: double.infinity,
        color: LinoColors.primary,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 1),
              Image.asset('assets/logos/logo_without_bird.png', height: 150),
              Spacer(flex: 1),
              _buildTextField(_usernameController, 'Username', Icons.person),
              SizedBox(height: 20),
              _buildTextField(_passwordController, 'Password', Icons.lock, obscureText: _obscureText),
              SizedBox(height: 20),
              _buildTextField(_emailController, 'Email', Icons.email),
              SizedBox(height: 20),
              _buildTextField(_phoneController, 'Phone', Icons.phone),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: Text('Dismiss', style: TextStyle(color: LinoColors.accent)),
                  ),
                  ElevatedButton(
                    onPressed: _showConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LinoColors.accent,
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white, // Change this to your desired text color
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
        filled: true,
        fillColor: LinoColors.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.black.withOpacity(0.5)),
        suffixIcon: hintText == 'Password'
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.black.withOpacity(0.5),
          ),
          onPressed: _togglePasswordVisibility,
        )
            : null,
      ),
      obscureText: obscureText,
    );
  }
}
