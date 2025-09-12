// app/lib/views/login/login_page.dart
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/login/login_view_model.dart';
import 'package:Lino_app/l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF4277B8),
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

  Widget _buildCloseButton() {
    return Positioned(
      top: 50,
      left: 16,
      child: IconButton(
        onPressed: () => Get.offAllNamed(AppRoutes.home.main),
        icon: const Icon(
          Icons.close,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildMainContent(LoginViewModel viewModel, AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Image.asset('assets/logos/logo_with_bird.png', height: 150),
          const Spacer(flex: 1),
          _buildTextField(
            viewModel.identifierController,
            localizations.emailorusername,
            Icons.person,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            viewModel.passwordController,
            localizations.password,
            Icons.lock,
            obscureText: viewModel.obscureText,
            onToggleVisibility: viewModel.togglePasswordVisibility,
          ),
          const SizedBox(height: 20),
          _buildLoginButton(viewModel, localizations),
          const Spacer(flex: 1),
          _buildFooterText(viewModel, localizations),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hintText,
      IconData icon, {
        bool obscureText = false,
        VoidCallback? onToggleVisibility,
      }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.3)),
        filled: true,
        fillColor: const Color(0xFFE0F7FA),
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
    );
  }

  Widget _buildLoginButton(LoginViewModel viewModel, AppLocalizations localizations) {
    return ElevatedButton(
      onPressed: viewModel.isLoading
          ? null
          : () async {
        final success = await viewModel.login();
        if (success && mounted) {
          Get.offAllNamed(AppRoutes.home.main);
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
      ),
      child: viewModel.isLoading
          ? const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      )
          :  Text(localizations.navLogIn),
    );
  }

  Widget _buildFooterText(LoginViewModel viewModel, AppLocalizations localizations) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: localizations.donthaveaccount,
              style: const TextStyle(color: Colors.white),
              children: [
                TextSpan(
                  text: localizations.register,
                  style: const TextStyle(
                    color: Color(0xFF063F6A),
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Get.toNamed(AppRoutes.auth.register);
                    },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              await viewModel.openAsGuest();
              if (mounted) {
                Get.offNamed(AppRoutes.home.main);
              }
            },
            child: Text(
              localizations.continueasguest,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}