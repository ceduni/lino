// app/lib/views/modify_profile_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/vm/profile/options/modify_profile_view_model.dart';
import 'package:Lino_app/utils/constants/colors.dart';

class ModifyProfilePage extends StatefulWidget {
  const ModifyProfilePage({super.key});

  @override
  _ModifyProfilePageState createState() => _ModifyProfilePageState();
}

class _ModifyProfilePageState extends State<ModifyProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModifyProfileViewModel>().loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Profile'),
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
                            backgroundImage: viewModel.profileImage != null
                                ? FileImage(viewModel.profileImage!)
                                : null,
                            child: viewModel.profileImage == null
                                ? Icon(
                                    Icons.person,
                                    size: 70,
                                    color: LinoColors.accent,
                                  )
                                : null,
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
                    _buildTextField(viewModel.usernameController, 'Username', Icons.person),
                    SizedBox(height: 20),
                    _buildTextField(
                      viewModel.passwordController,
                      'Password',
                      Icons.lock,
                      obscureText: viewModel.obscureText,
                      isPassword: true,
                      onVisibilityToggle: viewModel.togglePasswordVisibility,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(viewModel.emailController, 'Email', Icons.email),
                    SizedBox(height: 20),
                    _buildTextField(viewModel.phoneController, 'Phone', Icons.phone, isPhone: true),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                          child: Text('Dismiss', style: TextStyle(color: LinoColors.accent)),
                        ),
                        ElevatedButton(
                          onPressed: () => _showConfirmationDialog(viewModel),
                          style: ElevatedButton.styleFrom(backgroundColor: LinoColors.accent),
                          child: Text(
                            'Submit',
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