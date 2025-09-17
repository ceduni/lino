// app/lib/views/modify_profile_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/profile/options/modify_profile_view_model.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/l10n/app_localizations.dart';

class ModifyProfilePage extends StatefulWidget {
  const ModifyProfilePage({super.key});

  @override
  _ModifyProfilePageState createState() => _ModifyProfilePageState();
}

class _ModifyProfilePageState extends State<ModifyProfilePage> {
  int _visibilityToggleCount = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModifyProfileViewModel>().loadUserData();
    });
  }

  void _handlePasswordVisibilityToggle() {
    _visibilityToggleCount++;
    context.read<ModifyProfileViewModel>().togglePasswordVisibility();
    
    if (_visibilityToggleCount == 5) {
      _showHiPopup();
      _visibilityToggleCount = 0; // Reset counter
    }
  }

  void _showHiPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hi!'),
        content: Text('jalal was here :)'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.modifyProfile),
      ),
      body: Consumer<ModifyProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: LinoColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(flex: 1),
                    //Image.asset('assets/logos/logo_without_bird.png', height: 150),
                    GestureDetector(
                      onTap: () {
                        viewModel.showImagePickerOptions(context);
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.lightBlue[100],
                            backgroundImage: _getProfileImage(viewModel),
                            child: _getProfileImage(viewModel) == null
                                ? Icon(
                                    Icons.person,
                                    size: 70,
                                    color: LinoColors.accent,
                                  )
                                : null,
                          ),
                          if (viewModel.isUploadingImage)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 4,
                                  color: Colors.white,
                                ),
                                color: LinoColors.accent,
                              ),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(flex: 1),
                    _buildTextField(viewModel.usernameController, localizations.username, Icons.person),
                    SizedBox(height: 20),
                    _buildTextField(
                      viewModel.passwordController,
                      localizations.password,
                      Icons.lock,
                      obscureText: viewModel.obscureText,
                      isPassword: true,
                      onVisibilityToggle: _handlePasswordVisibilityToggle,
                      
                    ),
                    SizedBox(height: 20),
                    _buildTextField(viewModel.emailController, 'Email', Icons.email),
                    SizedBox(height: 20),
                    _buildTextField(viewModel.phoneController, localizations.phone, Icons.phone, isPhone: true),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                          child: Text(localizations.dismiss, style: TextStyle(color: LinoColors.accent)),
                        ),
                        ElevatedButton(
                          onPressed: () => _showConfirmationDialog(viewModel),
                          style: ElevatedButton.styleFrom(backgroundColor: LinoColors.accent),
                          child: Text(
                            localizations.submit,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                    
                    Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ImageProvider? _getProfileImage(ModifyProfileViewModel viewModel) {
    // Priority: local file > network URL > null
    if (viewModel.profileImage != null) {
      return FileImage(viewModel.profileImage!);
    } else if (viewModel.profilePictureUrl != null && viewModel.profilePictureUrl!.isNotEmpty) {
      return NetworkImage(viewModel.profilePictureUrl!);
    }
    return null;
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hintText,
      IconData icon, {
        bool obscureText = false,
        bool isPassword = false,
        bool isPhone = false,
        VoidCallback? onVisibilityToggle,
      }) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.3)),
        filled: true,
        fillColor: LinoColors.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.black.withValues(alpha: 0.5)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.black.withValues(alpha: 0.5),
          ),
          onPressed: onVisibilityToggle,
        )
            : null,
      ),
      obscureText: obscureText,
    );
  }

  void _showConfirmationDialog(ModifyProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Changes'),
        content: Text('Are you sure you want to update your profile?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(result: true);
              final success = await viewModel.updateUser();
              if (success) {
                Get.back();
              }
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}