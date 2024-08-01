import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Lino_app/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'keyword_input_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final SharedPreferences prefs;
  const RegisterPage({required this.prefs, super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool _obscureText = true;

  void _register() async {
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (username.length < 4 || username.length > 16) {
      _showError('Username must be between 4 and 16 characters.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email address.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _userService.registerUser(
        username,
        email,
        password,
        phone: _phoneController.text,
      );
      widget.prefs.setString('token', token);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomeScreen(username: username, token: token, prefs: widget.prefs),
        ),
            (route) => false, // Remove all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFF4277B8),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 2),
              Image.asset('assets/logos/logo_with_bird.png', height: 150),
              Spacer(flex: 1),
              _buildTextField(_usernameController, 'Username', Icons.person),
              SizedBox(height: 20),
              _buildTextField(_emailController, 'Email', Icons.email),
              SizedBox(height: 20),
              _buildTextField(_passwordController, 'Password', Icons.lock, obscureText: _obscureText),
              SizedBox(height: 20),
              _buildTextField(_phoneController, 'Phone (optional)', Icons.phone, inputType: TextInputType.phone, inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ]),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text('Register'),
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

  Widget _buildTextField(
      TextEditingController controller,
      String hintText,
      IconData icon, {
        bool obscureText = false,
        TextInputType inputType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
        filled: true,
        fillColor: Color(0xFFE0F7FA),
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
      keyboardType: inputType,
      inputFormatters: inputFormatters,
    );
  }

  Widget _buildFooterText() {
    return Container(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage(prefs: widget.prefs)),
          );
        },
        child: RichText(
          text: TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(color: Colors.white),
            children: const [
              TextSpan(
                text: 'Log in',
                style: TextStyle(
                  color: Color(0xFF063F6A),
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  final String username;
  final String token;
  final SharedPreferences prefs;

  const WelcomeScreen({required this.username, required this.token, required this.prefs, super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => KeywordInputPage(username: widget.username, token: widget.token, prefs: widget.prefs)),
            (route) => false, // Remove all previous routes
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4277B8),
      body: Center(
        child: Text(
          'Welcome, ${widget.username}!',
          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
