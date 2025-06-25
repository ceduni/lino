import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:Lino_app/config/image_config.dart';

class ImageUploadService {
  static const String _baseUrl = 'https://api.imgbb.com/1/upload';
  
  /// Uploads an image file to ImgBB and returns the public URL
  /// Returns null if upload fails
  Future<String?> uploadImage(File imageFile) async {
    // Check if API key is configured
    if (!ImageConfig.isImgbbConfigured) {
      print('ImgBB API key not configured.');
      return null;
    }
    
    try {
      // Compress the image before uploading
      final compressedImage = await _compressImage(imageFile);
      if (compressedImage == null) {
        print('Failed to compress image');
        return null;
      }
      
      // Convert to base64
      final bytes = await compressedImage.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // Prepare the request
      final uri = Uri.parse(_baseUrl);
      final request = http.MultipartRequest('POST', uri);
      
      // Add API key and image data
      request.fields['key'] = ImageConfig.imgbbApiKey;
      request.fields['image'] = base64Image;
      request.fields['expiration'] = '0'; // Never expire
      
      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        if (jsonResponse['success'] == true) {
          final imageUrl = jsonResponse['data']['url'];
          print('Image uploaded successfully: $imageUrl');
          return imageUrl;
        } else {
          print('Upload failed: ${jsonResponse['error']['message']}');
          return null;
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        print('Response: $responseBody');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
  
  /// Compresses an image to reduce file size
  /// Uses configuration values for max dimensions and quality
  Future<File?> _compressImage(File imageFile) async {
    try {
      // Read the image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        print('Failed to decode image');
        return null;
      }
      
      // Resize if too large (maintain aspect ratio)
      img.Image resizedImage = image;
      if (image.width > ImageConfig.maxImageWidth || image.height > ImageConfig.maxImageHeight) {
        resizedImage = img.copyResize(
          image,
          width: image.width > image.height ? ImageConfig.maxImageWidth : null,
          height: image.height > image.width ? ImageConfig.maxImageHeight : null,
        );
      }
      
      // Compress and save to temporary file
      final compressedBytes = img.encodeJpg(resizedImage, quality: ImageConfig.imageQuality);
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);
      
      return tempFile;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }
}
