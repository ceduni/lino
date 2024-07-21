import 'package:Lino_app/pages/login/register_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:Lino_app/nav_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final SharedPreferences prefs;
  const LoginPage({required this.prefs, Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserService _userService = UserService();

  void _login() async {
    try {
      final token = await _userService.loginUser(
        _identifierController.text,
        _passwordController.text,
      );
      widget.prefs.setString('token', token);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavigationMenu()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFF4277B8), // Darker blue background
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 2),
              Image.asset('assets/logos/logo_with_bird.png', height: 150), // Logo near the top
              Spacer(flex: 1),
              _buildTextField(_identifierController, 'Username or Email', Icons.person),
              SizedBox(height: 20),
              _buildTextField(_passwordController, 'Password', Icons.lock, obscureText: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                ),
                child: Text('Login'),
              ),
              Spacer(flex: 1),
              _buildFooterText(),
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
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)), // Less opaque placeholder text
        filled: true,
        fillColor: Color(0xFFE0F7FA), // Clearer blue background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0), // Rounded borders
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.black.withOpacity(0.5)),
      ),
      obscureText: obscureText,
    );
  }

  Widget _buildFooterText() {
    return Container(
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: 'Register here',
              style: TextStyle(
                color: Color(0xFF063F6A),
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage(prefs: widget.prefs)),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
