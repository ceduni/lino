import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:Lino_app/config/image_config.dart';

class ImageUploadService {
  static String get _baseUrl =>
      'https://api.cloudflare.com/client/v4/accounts/${ImageConfig.accountId}/images/v1';

  /// Uploads an image file to Cloudflare Images CDN and returns the public URL
  /// Returns null if upload fails
  Future<String?> uploadImage(File imageFile) async {
    // Check if API token is configured
    if (!ImageConfig.isCloudflareConfigured()) {
      print('Cloudflare API token not configured.');
      return null;
    }

    try {
      // Get API token
      final apiToken = ImageConfig.getCloudflareApiToken();

      // Compress the image before uploading
      final compressedImage = await _compressImage(imageFile);
      if (compressedImage == null) {
        print('Failed to compress image');
        return null;
      }

      // Check file size
      final fileSize = await compressedImage.length();
      if (fileSize > ImageConfig.maxFileSizeMB * 1024 * 1024) {
        print('File size exceeds ${ImageConfig.maxFileSizeMB}MB limit');
        return null;
      }

      // Prepare the multipart request
      final uri = Uri.parse(_baseUrl);
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $apiToken';

      // Add the image file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        compressedImage.path,
        filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      // Add metadata (optional)
      request.fields['metadata'] = json.encode({
        'uploaded_at': DateTime.now().toIso8601String(),
        'app': 'Lino_app',
      });

      // Set requireSignedURLs to false for public access
      request.fields['requireSignedURLs'] = 'false';

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        if (jsonResponse['success'] == true) {
          // Get the public URL from variants
          final variants = jsonResponse['result']['variants'] as List;
          if (variants.isNotEmpty) {
            // Use the public variant (first one is usually the original/public)
            final imageUrl = variants.first as String;
            print('Image uploaded successfully: $imageUrl');

            // Clean up temporary compressed file
            try {
              await compressedImage.delete();
            } catch (e) {
              print('Warning: Failed to delete temporary file: $e');
            }

            return imageUrl;
          } else {
            print('No image variants returned');
            return null;
          }
        } else {
          print('Upload failed: ${jsonResponse['errors']}');
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