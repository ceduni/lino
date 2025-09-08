// app/lib/vm/modify_profile_view_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:Lino_app/services/user_services.dart';

class ModifyProfileViewModel extends ChangeNotifier {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  late String _token;
  bool _isLoading = true;
  bool _obscureText = true;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  bool get isLoading => _isLoading;
  bool get obscureText => _obscureText;
  File? get profileImage => _profileImage;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token')!;
    final userService = UserService();
    final user = await userService.getUser(_token);

    usernameController = TextEditingController(text: user.username);
    passwordController = TextEditingController(text: '');
    emailController = TextEditingController(text: user.email);
    phoneController = TextEditingController(text: user.phone ?? '');

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUser() async {
    final userService = UserService();
    try {
      await userService.updateUser(
        _token,
        username: usernameController.text,
        password: passwordController.text.isEmpty ? null : passwordController.text,
        email: emailController.text,
        phone: phoneController.text,
      );
      showToast('Profile updated successfully');
      return true;
    } catch (e) {
      showToast('Failed to update profile');
      print('Failed to update profile: $e');
      return false;
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

  void togglePasswordVisibility() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      
      if (image != null) {
        _profileImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      showToast('Failed to pick image');
      print('Error picking image: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      
      if (image != null) {
        _profileImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      showToast('Failed to take photo');
      print('Error taking photo: $e');
    }
  }

  void showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImageFromCamera();
                },
              ),
              if (_profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _profileImage = null;
                    notifyListeners();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}