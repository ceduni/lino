// app/lib/views/login/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Lino_app/vm/login/register_view_model.dart';
import 'onboarding/favourite_genres_input_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final SharedPreferences prefs;
  const RegisterPage({required this.prefs, super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RegisterViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF4277B8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Image.asset('assets/logos/logo_with_bird.png', height: 150),
                  const Spacer(flex: 1),
                  _buildTextField(viewModel.usernameController, 'Username', Icons.person),
                  const SizedBox(height: 20),
                  _buildTextField(viewModel.emailController, 'Email', Icons.email),
                  const SizedBox(height: 20),
                  _buildTextField(
                    viewModel.passwordController,
                    'Password',
                    Icons.lock,
                    obscureText: viewModel.obscureText,
                    onToggleVisibility: viewModel.togglePasswordVisibility,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    viewModel.phoneController,
                    'Phone (optional)',
                    Icons.phone,
                    inputType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildRegisterButton(viewModel),
                  const Spacer(flex: 1),
                  _buildFooterText(),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          );
        },
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
        VoidCallback? onToggleVisibility,
      }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
        filled: true,
        fillColor: const Color(0xFFE0F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.black.withOpacity(0.5)),
        suffixIcon: hintText == 'Password'
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.black.withOpacity(0.5),
          ),
          onPressed: onToggleVisibility,
        )
            : null,
      ),
      obscureText: obscureText,
      keyboardType: inputType,
      inputFormatters: inputFormatters,
    );
  }

  Widget _buildRegisterButton(RegisterViewModel viewModel) {
    return ElevatedButton(
      onPressed: viewModel.isLoading
          ? null
          : () async {
        final token = await viewModel.register(widget.prefs);
        if (token != null && mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomeScreen(
                username: viewModel.usernameController.text,
                token: token,
                prefs: widget.prefs,
              ),
            ),
                (route) => false,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
      ),
      child: viewModel.isLoading
          ? const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      )
          : const Text('Register'),
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
          text: const TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(color: Colors.white),
            children: [
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

  const WelcomeScreen({
    required this.username,
    required this.token,
    required this.prefs,
    super.key,
  });

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => FavouriteGenresInputPage(
              token: widget.token,
              prefs: widget.prefs,
            ),
          ),
              (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4277B8),
      body: Center(
        child: Text(
          'Welcome, ${widget.username}!',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}