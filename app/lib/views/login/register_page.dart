// app/lib/views/login/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/login/register_view_model.dart';
import '../../utils/constants/routes.dart';
import 'package:Lino_app/l10n/app_localizations.dart';
import 'package:Lino_app/utils/constants/colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Consumer<RegisterViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Stack(
              children: [
                _buildCloseButton(),
                _buildMainContent(viewModel, localizations),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(RegisterViewModel viewModel, AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Image.asset('assets/logos/logo_with_bird.png', height: 150),
          const Spacer(flex: 1),
          _buildTextField(viewModel.usernameController, localizations.username, Icons.person),
          const SizedBox(height: 20),
          _buildTextField(viewModel.emailController, 'Email', Icons.email),
          const SizedBox(height: 20),
          _buildTextField(
            viewModel.passwordController,
            localizations.password,
            Icons.lock,
            obscureText: viewModel.obscureText,
            onToggleVisibility: viewModel.togglePasswordVisibility,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            viewModel.phoneController,
            localizations.phoneNumber,
            Icons.phone,
            inputType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
          ),
          const SizedBox(height: 20),
          _buildRegisterButton(viewModel, localizations),
          const Spacer(flex: 1),
          _buildFooterText(localizations),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 50,
      left: 16,
      child: IconButton(
        onPressed: () => Get.offAllNamed(AppRoutes.auth.login),
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
          size: 30,
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
        VoidCallback? onToggleVisibility,
      }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.3)),
        filled: true,
         fillColor: Color.fromARGB(240, 240, 240, 255),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.black.withValues(alpha: 0.5)),
        suffixIcon: hintText == 'Password'
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.black.withValues(alpha: 0.5),
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

  Widget _buildRegisterButton(RegisterViewModel viewModel, AppLocalizations localizations) {
    return ElevatedButton(
      onPressed: viewModel.isLoading
          ? null
          : () async {
        final token = await viewModel.register();
        if (token != null && mounted) {
          
          Get.offAllNamed(AppRoutes.home.main);
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
        backgroundColor: LinoColors.accent,
      ),
      child: viewModel.isLoading
          ? const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      )
          :  Text(localizations.registerbtn, style: const TextStyle(color: Colors.white))
    );
  }

  Widget _buildFooterText(AppLocalizations localizations) {
    return Container(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          Get.offNamed(AppRoutes.auth.login);
        },
        child: RichText(
          text: TextSpan(
            text: localizations.alreadyHaveAccount,
            style: const TextStyle(color: Colors.black),
            children: [
              TextSpan(
                text: localizations.navLogIn,
                style: const TextStyle(
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
  const WelcomeScreen({
    super.key,
  });

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late String username;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    username = args['username'] ?? '';

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Get.offAllNamed(AppRoutes.auth.onboarding.favouriteGenres);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4277B8),
      body: Center(
        child: Text(
          'Welcome, $username!',
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