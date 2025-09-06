import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(File?) onImageSelected;
  final File? initialImage;
  final String? placeholder;

  const ImagePickerWidget({
    Key? key,
    required this.onImageSelected,
    this.initialImage,
    this.placeholder,
  }) : super(key: key);

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Remove Image', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Get.back();
                    _removeImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Check and request permissions
      bool hasPermission = await _checkPermissions(source);
      if (!hasPermission) {
        _showPermissionDialog();
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        setState(() {
          _selectedImage = imageFile;
        });
        widget.onImageSelected(imageFile);
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorDialog('Failed to pick image. Please try again.');
    }
  }

  Future<bool> _checkPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      final cameraStatus = await Permission.camera.status;
      if (cameraStatus.isDenied) {
        final result = await Permission.camera.request();
        return result.isGranted;
      }
      return cameraStatus.isGranted;
    } else {
      // For gallery access on different platforms
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.status;
        if (storageStatus.isDenied) {
          final result = await Permission.storage.request();
          return result.isGranted;
        }
        return storageStatus.isGranted;
      } else if (Platform.isIOS) {
        final photosStatus = await Permission.photos.status;
        if (photosStatus.isDenied) {
          final result = await Permission.photos.request();
          return result.isGranted;
        }
        return photosStatus.isGranted;
      }
    }
    return true;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text('This app needs permission to access your camera and photos to add cover images.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Get.back(),
            ),
            TextButton(
              child: Text('Open Settings'),
              onPressed: () {
                Get.back();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Get.back(),
            ),
          ],
        );
      },
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: _selectedImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.white, size: 20),
                        onPressed: _showImageSourceDialog,
                        constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.placeholder ?? 'Add Cover Image',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap to select from camera or gallery',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
