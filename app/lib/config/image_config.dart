import 'package:flutter_dotenv/flutter_dotenv.dart';

// Image Upload Configuration
// 
// This file contains configuration for the image upload service.
// The API key is now read from .env file for cross-platform compatibility

class ImageConfig {
  // Image Settings
  static const int maxImageWidth = 800;
  static const int maxImageHeight = 800;
  static const int imageQuality = 85; // 0-100, higher = better quality but larger file
  static const int maxFileSizeMB = 10; // Maximum file size in MB
  
  /// Gets the ImgBB API key from .env file
  static String getImgbbApiKey() {
    return dotenv.env['IMGBB_API_KEY'] ?? 'YOUR_IMGBB_API_KEY_HERE';
  }
  
  /// Checks if ImgBB is properly configured
  static bool isImgbbConfigured() {
    final apiKey = getImgbbApiKey();
    return apiKey != 'YOUR_IMGBB_API_KEY_HERE' && apiKey.isNotEmpty;
  }
}
