import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:Lino_app/services/image_upload_service.dart';
import 'dart:io';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isUploading = false;
  String? _capturedImagePath;

  final ImageUploadService _imageUploadService = ImageUploadService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Automatically open camera when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _takePicture();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 235, 1),
      appBar: AppBar(
        title: const Text(
          'Book Cover Photo',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(101, 67, 33, 1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _capturedImagePath != null
            ? _buildPreviewScreen()
            : _buildCameraOptionsScreen(),
      ),
    );
  }

  Widget _buildCameraOptionsScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt,
              size: 80,
              color: Color.fromRGBO(101, 67, 33, 1),
            ),
            const SizedBox(height: 32),
            const Text(
              'Add Book Cover Photo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Kanit',
                color: Color.fromRGBO(101, 67, 33, 1),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Take a photo of the book cover to add it to your book details',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Kanit',
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text(
                  'Take Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(101, 67, 33, 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewScreen() {
    return Column(
      children: [
        // Preview image
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_capturedImagePath!),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        
        // Action buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: _isUploading
              ? const Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(101, 67, 33, 1)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Uploading image...',
                      style: TextStyle(
                        color: Color.fromRGBO(101, 67, 33, 1),
                        fontFamily: 'Kanit',
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _retakePicture,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Retake',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _uploadAndConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Use Photo',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        setState(() {
          _capturedImagePath = image.path;
        });
      } else {
        // User cancelled, go back
        Get.back();
      }
    } catch (e) {
      print('Error taking picture: $e');
      _showErrorDialog('Failed to take picture. Please try again.');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        setState(() {
          _capturedImagePath = image.path;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorDialog('Failed to pick image. Please try again.');
    }
  }

  void _retakePicture() {
    setState(() {
      _capturedImagePath = null;
    });
  }

  Future<void> _uploadAndConfirm() async {
    if (_capturedImagePath == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final imageFile = File(_capturedImagePath!);
      final imageUrl = await _imageUploadService.uploadImage(imageFile);
      
      if (imageUrl != null) {
        // Return the uploaded image URL
        Get.back(result: imageUrl);
      } else {
        _showErrorDialog('Failed to upload image. Please try again.');
      }
    } catch (e) {
      print('Error uploading image: $e');
      _showErrorDialog('Failed to upload image. Please check your internet connection.');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Error',
          style: TextStyle(fontFamily: 'Kanit'),
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Kanit'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'OK',
              style: TextStyle(fontFamily: 'Kanit'),
            ),
          ),
        ],
      ),
    );
  }
}
